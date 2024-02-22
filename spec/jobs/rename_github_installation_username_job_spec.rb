require 'rails_helper'

RSpec.describe RenameGithubInstallationUsernameJob do
  context 'when github installation has multiple repositories' do
    before(:all) do
      # Create repositories and their directories in `repos` folder
      @github_installation = create(:github_installation)
      create(:repository, github_installation: @github_installation)
      create(:repository, :second, github_installation: @github_installation)
      @directories = @github_installation.list_repository_directories
      @directories.each do |directory|
        FileUtils.mkdir_p(directory)
        FileUtils.touch(directory.join('index.md'))
      end

      @new_username = 'new-user'
    end

    after(:all) do
      parent_directory = Rails.root.join('repos', @github_installation.author.github_username)
      FileUtils.remove_dir(parent_directory)
    end

    it 'queues the job' do
      described_class.perform_async(
        @github_installation.id,
        @new_username
      )
      expect(described_class).to have_enqueued_sidekiq_job(
        @github_installation.id,
        @new_username
      )
    end

    context 'when executing perform' do
      before(:all) do
        Sidekiq::Testing.inline! do
          described_class.perform_async(
            @github_installation.id,
            @new_username
          )
        end
      end

      it "modifies the github installation's information" do
        @github_installation.reload
        expect(@github_installation.username).to eq(@new_username)
      end

      it 'changes the directory where repositories are stored' do
        @directories.each do |directory|
          expect(File).not_to exist(directory)
        end
        @github_installation.reload
        new_directories = @github_installation.list_repository_directories
        new_directories.each do |new_directory|
          expect(File).to exist(new_directory)
        end
      end
    end
  end

  context 'when github installation has no repositories' do
    before(:all) do
      @github_installation = create(:github_installation, :real)
      @new_username = 'jp'
    end

    it 'queues the job' do
      described_class.perform_async(
        @github_installation.id,
        @new_username
      )
      expect(described_class).to have_enqueued_sidekiq_job(
        @github_installation.id,
        @new_username
      )
    end

    context 'when executing perform' do
      before do
        Sidekiq::Testing.inline! do
          described_class.perform_async(
            @github_installation.id,
            @new_username
          )
        end
      end

      it "modifies the github installation's information" do
        @github_installation.reload
        expect(@github_installation.username).to eq(@new_username)
      end
    end
  end
end
