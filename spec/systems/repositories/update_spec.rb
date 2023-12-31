require 'rails_helper'

RSpec.describe Repository, '#update', type: :system do
  before(:all) do
    @repo = create(:repository, :real)
    clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
    Sidekiq::Testing.inline! do
      VCR.use_cassette('clone_github_repo') do
        CloneGithubRepoJob.perform_async(clone_build.id)
      end
    end
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end

  context 'when logged in as an author' do
    before(:all) do
      Sidekiq::Testing.inline! do
        author = @repo.author
        sign_in author.user
        page.set_rack_session(author_id: author.id)

        visit edit_settings_author_repository_path(@repo.id)
        VCR.use_cassette('rebuild_repo') do
          click_on 'Rebuild repository (pull from GitHub)'
        end

        sleep(1)
        @rebuild_build = @repo.builds.last
      end
    end

    context 'when rebuilding the repository' do
      it "creates an associated Build with action 'rebuild'" do
        expect(@rebuild_build.action).to eq('rebuild')
      end

      it 'creates the first log' do
        expect(@rebuild_build.logs.first.content).to eq('Repository successfully pulled.')
      end

      it 'creates the second log' do
        expect(@rebuild_build.logs.second.content).to eq('Repository description successfully updated from GitHub.')
      end

      it 'with the third log' do
        expect(@rebuild_build.logs.third.content).to eq('Questions successfully parsed.')
      end

      it 'creates the fourth log' do
        expect(@rebuild_build.logs.fourth.content).to eq('index.md file exists for this repository.')
      end

      it "sets Build status to 'Complete'" do
        @rebuild_build.reload
        expect(@rebuild_build.status).to eq('Complete')
      end
    end
  end
end
