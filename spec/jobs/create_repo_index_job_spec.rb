require 'rails_helper'

RSpec.describe CreateRepoIndexJob do
  before(:all) do
    @repo = create(:repository, last_pull_at: DateTime.current)

    @build = create(:build, repository: @repo, aasm_state: :creating_repo_index)
    @destination_directory = Rails.root.join('repos', @repo.full_name)
    source_directory = Rails.root.join('spec/fixtures/jobs/create_repo_index')
    FileUtils.mkdir_p(@destination_directory)
    FileUtils.copy_entry(source_directory, @destination_directory)
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.owner)
    FileUtils.remove_dir(parent_directory)
  end

  it 'queues the job' do
    described_class.perform_async(@build.id)
    expect(described_class).to have_enqueued_sidekiq_job(@build.id)
  end

  context "when the 'index.md' file exists" do
    before do
      filepath = File.join(@destination_directory, 'index.md')
      File.write(filepath, 'Index file content')
    end

    after do
      filepath = Rails.root.join('repos', @repo.full_name, 'index.md')
      File.delete(filepath)
    end

    it 'does not create a new file' do
      Sidekiq::Testing.inline! do
        build = create(:build, repository: @repo, aasm_state: :creating_repo_index)
        described_class.perform_async(build.id)
      end

      index_filepath = Rails.root.join('repos', @repo.full_name, 'index.md')
      file_data = File.read(index_filepath)
      expect(file_data).to eq('Index file content')
    end
  end

  context "when the 'index.md' file does not exist" do
    before(:all) do
      Sidekiq::Testing.inline! do
        described_class.perform_async(@build.id)
      end
      @index_filepath = Rails.root.join('repos', @repo.full_name, 'index.md')
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
end
