require 'rails_helper'

RSpec.describe CreateRepoIndexJob, type: :job do
  before(:all) do
    @repo = create(:repository, last_pull_at: DateTime.current)
    @build = create(:build, repository: @repo)
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    folder_directory = directory.join('Folder')
    FileUtils.mkdir_p(folder_directory)

    first_filepath = File.join(directory, 'article_one.md')
    File.open(first_filepath, 'w') { |f| f.write('Article one content') }

    second_filepath = File.join(directory, 'Folder', 'article_two.md')
    File.open(second_filepath, 'w') { |f| f.write('Article two content') }
  end

  it 'queues the job' do
    CreateRepoIndexJob.perform_async(@repo.id, @build.id)
    expect(CreateRepoIndexJob).to have_enqueued_sidekiq_job(@repo.id, @build.id)
  end

  context "when the 'index.md' file exists" do
    before do
      directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
      filepath = File.join(directory, 'index.md')
      File.open(filepath, 'w') { |f| f.write('Index file content') }
    end

    it 'does not create a new file' do
      Sidekiq::Testing.inline! do
        CreateRepoIndexJob.perform_async(@repo.id, @build.id)
      end

      index_filepath = Rails.root.join('repos', @repo.author.github_username, @repo.name, 'index.md')
      file_data = File.read(index_filepath)
      expect(file_data).to eq('Index file content')
    end

    after do
      filepath = Rails.root.join('repos', @repo.author.github_username, @repo.name, 'index.md')
      File.delete(filepath)
    end
  end

  context "when the 'index.md' file does not exist" do
    before(:all) do
      Sidekiq::Testing.inline! do
        CreateRepoIndexJob.perform_async(@repo.id, @build.id)
      end
      @index_filepath = Rails.root.join('repos', @repo.author.github_username, @repo.name, 'index.md')
      @file_data = File.read(@index_filepath)
    end

    it 'creates a new file' do
      expect(File.exist?(@index_filepath)).to be(true)
    end

    it 'creates a new file with front matter' do
      expect(@file_data).to include("title: #{@repo.title.titleize}")
      expect(@file_data).to include("date: #{@repo.last_pull_at.to_date}")
      expect(@file_data).to include("author: #{@repo.author.name}")
    end

    it 'creates a new file with links to other pages' do
      expect(@file_data).to include('* [Article One](./article_one)')
      expect(@file_data).to include('* [Folder/Article Two](./Folder/article_two)')
    end
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author.github_username)
    directory = parent_directory.join(@repo.name)
    FileUtils.remove_dir(directory)
    FileUtils.remove_dir(parent_directory)
  end
end
