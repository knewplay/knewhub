require 'rails_helper'

RSpec.describe 'Settings::AuthorSpace::Repositories#create', type: :system do
  context 'without using the Build process' do
    let(:author) { create(:author) }

    context 'when given valid name and token, but no branch' do
      scenario 'creates the repository' do
        sign_in author.user
        page.set_rack_session(author_id: author.id)
        visit new_settings_author_repository_path
        expect(page).to have_content('New Repository')

        fill_in('Name', with: 'repo_name')
        fill_in('Title', with: 'Test Repo')
        fill_in('Token', with: 'ghp_abcde12345')
        click_on 'Create Repository'

        expect(page).to have_content('Repository was successfully created.')
        expect(Repository.last.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')
        expect(Repository.last.token).to eq('ghp_abcde12345')
        expect(Repository.last.branch).to eq('main')
      end
    end

    context 'when given valid name, token and branch' do
      scenario 'creates the repository' do
        sign_in author.user
        page.set_rack_session(author_id: author.id)
        visit new_settings_author_repository_path
        expect(page).to have_content('New Repository')

        fill_in('Name', with: 'repo_name')
        fill_in('Title', with: 'Test Repo')
        fill_in('Token', with: 'ghp_abcde12345')
        fill_in('Branch', with: 'some_branch')
        click_on 'Create Repository'

        expect(page).to have_content('Repository was successfully created.')
        expect(Repository.last.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')
        expect(Repository.last.token).to eq('ghp_abcde12345')
        expect(Repository.last.branch).to eq('some_branch')
      end
    end

    context 'when given invalid input' do
      scenario 'fails to create the repository' do
        sign_in author.user
        page.set_rack_session(author_id: author.id)
        visit new_settings_author_repository_path
        expect(page).to have_content('New Repository')

        fill_in('Name', with: 'repo_name')
        fill_in('Title', with: 'Test Repo')
        fill_in('Token', with: 'abcde12345')
        click_on 'Create Repository'

        expect(page).to have_content('Token must start with "github_pat" or "ghp"')
      end
    end
  end

  context 'using the Build process' do
    before(:all) do
      author = create(:author, :real)
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit new_settings_author_repository_path
      expect(page).to have_content('New Repository')

      fill_in('Name', with: 'test-repo')
      fill_in('Title', with: 'Test Repo')
      fill_in('Token', with: Rails.application.credentials.pat)
      click_on 'Create Repository'

      @repo = Repository.last
      @repo.update(uuid: 'c3a3bf52-f983-4b1a-847a-be921fa97914')
      sleep(1)
      @build = @repo.builds.first

      Sidekiq::Testing.inline! do
        VCR.use_cassette('create_github_webhook_for_create') do
          CreateGithubWebhookJob.perform_async(@repo.id, @build.id)
        end
        VCR.use_cassette('clone_github_repo_for_create') do
          CloneGithubRepoJob.perform_async(@repo.id, @build.id)
        end
      end
    end

    scenario "creates an associated Build with action 'create'" do
      expect(@build.action).to eq('create')
    end

    scenario 'creates the first log' do
      log_content = @build.logs.first.content
      expect(log_content).to include('GitHub webhook successfully created.')
    end

    scenario 'creates the second log' do
      expect(@build.logs.second.content).to eq('GitHub webhook successfully tested.')
    end

    scenario 'creates the third log' do
      expect(@build.logs.third.content).to eq('Repository successfully cloned.')
    end

    scenario 'creates the fourth log' do
      expect(@build.logs.fourth.content).to eq('Repository description successfully updated from GitHub.')
    end

    scenario 'creates the fifth log' do
      expect(@build.logs.fifth.content).to eq('index.md file successfully generated.')
    end

    scenario "sets Build status to 'Complete'" do
      @build.reload
      expect(@build.status).to eq('Complete')
    end

    after(:all) do
      @repo.reload
      directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
      FileUtils.remove_dir(directory)

      log_content = @build.logs.first.content
      hook_id = log_content.match(/Hook ID: (\d+)/)[1].to_i

      VCR.use_cassette('delete_github_webhook_for_create') do
        client = Octokit::Client.new(access_token: @repo.token)
        client.remove_hook("#{@repo.author.github_username}/#{@repo.name}", hook_id)
      end
    end
  end
end
