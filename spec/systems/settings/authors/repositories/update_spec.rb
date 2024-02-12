require 'rails_helper'

RSpec.shared_context 'when updating a repository' do
  before do
    sign_in author.user
    visit edit_settings_author_repository_path(repo.id)
  end
end

RSpec.describe 'Settings::Authors::Repositories#update', type: :system do
  let(:repo) { create(:repository) }
  let(:author) { repo.author }

  context 'when given valid input' do
    context 'without the Build process' do
      include_context 'when updating a repository'

      it 'updates the title' do
        expect(page).to have_content('Edit Repository')

        fill_in('Title', with: 'New Repo Name')
        click_on 'Update Repository'

        expect(page).to have_content('Repository update process was initiated.')
        expect(page).to have_content('Title: New Repo Name')
      end

      it 'updates the branch' do
        expect(page).to have_content('Edit Repository')

        fill_in('Branch', with: 'other_branch')
        click_on 'Update Repository'

        expect(page).to have_content('Repository update process was initiated.')
        expect(page).to have_content('Branch: other_branch')

        repo.reload
        expect(repo.branch).to eq('other_branch')
      end
    end

    context 'when updating the branch and title using the Build process' do
      before(:all) do
        Sidekiq::Testing.inline! do
          # Creates and clones a repository
          @repo = create(:repository, :real)
          clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
          # HTTP request required to clone repository using Octokit client
          VCR.turn_off!
          WebMock.allow_net_connect!
          CloneGithubRepoJob.perform_async(clone_build.id)
          # Updates repository with a new name and title
          author = @repo.author
          sign_in author.user

          visit edit_settings_author_repository_path(@repo.id)
          fill_in('Branch', with: 'other')
          fill_in('Title', with: 'Test Repo')
          click_on 'Update Repository'

          sleep(1)
          @update_build = @repo.builds.last
        end
      end

      after(:all) do
        @repo.reload
        directory = Rails.root.join('repos', @repo.full_name)
        FileUtils.remove_dir(directory)
        VCR.turn_on!
        WebMock.disable_net_connect!
      end

      it "creates an associated Build with action 'update'" do
        expect(@update_build.action).to eq('update')
      end

      it 'creates the first log' do
        expect(@update_build.logs.first.content).to eq('Repository successfully cloned.')
      end

      it 'creates the second log' do
        expect(@update_build.logs.second.content).to eq('Repository description successfully updated from GitHub.')
      end

      it 'with the third log' do
        expect(@update_build.logs.third.content).to eq('Questions successfully parsed.')
      end

      it 'creates the fourth log' do
        expect(@update_build.logs.fourth.content).to eq('index.md file successfully generated.')
      end

      it "sets Build status to 'Complete'" do
        @update_build.reload
        expect(@update_build.status).to eq('Complete')
      end
    end
  end

  context 'when given invalid input' do
    it 'fails to update' do
      sign_in author.user

      visit edit_settings_author_repository_path(repo.id)
      expect(page).to have_content('Edit Repository')

      fill_in('Branch', with: 'invalid!branch')
      click_on 'Update Repository'

      expect(page).to have_content('Branch must follow GitHub branch name restrictions')
    end
  end
end
