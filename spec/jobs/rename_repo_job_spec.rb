require 'rails_helper'

RSpec.describe RenameRepoJob do
  before(:all) do
    # Create repository and its directory in `repos` folder
    @repo = create(:repository)
    @directory = @repo.storage_path
    FileUtils.mkdir_p(@directory)
    FileUtils.touch(@directory.join('index.md'))

    @new_name = 'new_repo_name'
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author_username)
    FileUtils.remove_dir(parent_directory)
  end

  it 'queues the job' do
    described_class.perform_async(
      @repo.id,
      @new_name
    )
    expect(described_class).to have_enqueued_sidekiq_job(
      @repo.id,
      @new_name
    )
  end

  context 'when executing perform' do
    before(:all) do
      Sidekiq::Testing.inline! do
        described_class.perform_async(
          @repo.id,
          @new_name
        )
      end
    end

    it "modifies the repository's information" do
      @repo.reload
      expect(@repo.name).to eq(@new_name)
      expect(@repo.full_name).to eq('repo_owner/new_repo_name')
    end

    it 'changes the directory where the repository is stored' do
      expect(File).not_to exist(@directory)
      @repo.reload
      new_directory = @repo.storage_path
      expect(File).to exist(new_directory)
    end
  end
end
