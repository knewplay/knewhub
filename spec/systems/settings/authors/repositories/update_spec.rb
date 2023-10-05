require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories#update', type: :system do
  let(:repo) { create(:repository) }
  let(:author) { repo.author }

  context 'when given valid input' do
    context 'without the Build process' do
      scenario 'updates the name' do
        sign_in author.user
        page.set_rack_session(author_id: author.id)

        visit edit_settings_author_repository_path(repo.id)
        expect(page).to have_content('Edit Repository')

        fill_in('Name', with: 'a_new_name')
        click_on 'Update Repository'

        expect(page).to have_content('Repository update process was initiated.')
        expect(page).to have_content('a_new_name')

        repo.reload
        expect(repo.git_url).to eq('https://ghp_abcde12345@github.com/user/a_new_name.git')
      end

      scenario 'updates the branch' do
        sign_in author.user
        page.set_rack_session(author_id: author.id)

        visit edit_settings_author_repository_path(repo.id)
        expect(page).to have_content('Edit Repository')

        fill_in('Branch', with: 'other_branch')
        click_on 'Update Repository'

        expect(page).to have_content('Repository update process was initiated.')

        repo.reload
        expect(repo.branch).to eq('other_branch')
      end
    end

    context 'updating the name and title using the Build process' do
      before(:all) do
        Sidekiq::Testing.inline! do
          # Creates and clones a repository
          @repo = create(:repository, :real)
          clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
          VCR.use_cassette('clone_github_repo') do
            CloneGithubRepoJob.perform_async(clone_build.id)
          end

          # Updates repository with a new name and title
          author = @repo.author
          sign_in author.user
          page.set_rack_session(author_id: author.id)

          visit edit_settings_author_repository_path(@repo.id)
          fill_in('Name', with: 'markdown-templates')
          fill_in('Title', with: 'Markdown Templates')
          VCR.use_cassette('update_repo') do
            click_on 'Update Repository'
          end

          sleep(1)
          @update_build = @repo.builds.last
        end
      end

      scenario "creates an associated Build with action 'update'" do
        expect(@update_build.action).to eq('update')
      end

      scenario 'creates the first log' do
        expect(@update_build.logs.first.content).to eq('Repository successfully cloned.')
      end

      scenario 'creates the second log' do
        expect(@update_build.logs.second.content).to eq('Repository description successfully updated from GitHub.')
      end

      scenario 'with the third log' do
        expect(@update_build.logs.third.content).to eq('Questions successfully parsed.')
      end

      scenario 'creates the fourth log' do
        expect(@update_build.logs.fourth.content).to eq('index.md file exists for this repository.')
      end

      scenario "sets Build status to 'Complete'" do
        @update_build.reload
        expect(@update_build.status).to eq('Complete')
      end

      after(:all) do
        @repo.reload
        directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
        FileUtils.remove_dir(directory)
      end
    end
  end

  context 'when given invalid input' do
    scenario 'fails to update' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit edit_settings_author_repository_path(repo.id)
      expect(page).to have_content('Edit Repository')

      fill_in('Branch', with: 'invalid!branch')
      click_on 'Update Repository'

      expect(page).to have_content('Branch must follow GitHub branch name restrictions')
    end
  end
end
