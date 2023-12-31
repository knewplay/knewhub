require 'rails_helper'

RSpec.shared_context 'when creating a new repository' do
  let(:author) { create(:author) }

  before do
    sign_in author.user
    page.set_rack_session(author_id: author.id)
    visit new_settings_author_repository_path
  end
end

RSpec.describe 'Settings::Authors::Repositories#create', type: :system do
  context 'without using the Build process' do
    include_context 'when creating a new repository'

    context 'when given valid name and token, but no branch' do
      it 'creates the repository' do
        expect(page).to have_content('New repository')

        fill_in('Name', with: 'repo_name')
        fill_in('Title', with: 'Test Repo')
        fill_in('Token', with: 'ghp_abcde12345')
        click_on 'Create Repository'

        expect(page).to have_content('Repository creation process was initiated.')
        expect(Repository.last.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')
        expect(Repository.last.branch).to eq('main')
      end
    end

    context 'when given valid name, token and branch' do
      it 'creates the repository' do
        expect(page).to have_content('New repository')

        fill_in('Name', with: 'repo_name')
        fill_in('Title', with: 'Test Repo')
        fill_in('Token', with: 'ghp_abcde12345')
        fill_in('Branch', with: 'some_branch')
        click_on 'Create Repository'

        expect(page).to have_content('Repository creation process was initiated.')
        expect(Repository.last.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')
        expect(Repository.last.branch).to eq('some_branch')
      end
    end

    context 'when given invalid input' do
      it 'fails to create the repository' do
        expect(page).to have_content('New repository')

        fill_in('Name', with: 'repo_name')
        fill_in('Title', with: 'Test Repo')
        fill_in('Token', with: 'abcde12345')
        click_on 'Create Repository'

        expect(page).to have_content('Token must start with "github_pat" or "ghp"')
      end
    end
  end

  context 'when using the Build process' do
    before(:all) do
      author = create(:author, :real)
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit new_settings_author_repository_path

      fill_in('Name', with: 'test-repo')
      fill_in('Title', with: 'Test Repo')
      fill_in('Token', with: Rails.application.credentials.pat)
      click_on 'Create Repository'

      @repo = Repository.last
      @repo.update(uuid: '42b189e0-5d63-4529-b863-198a9c259669')
      sleep(1)
      @build = @repo.builds.first

      # The job is called here to allow the `uuid` to be specified
      # This is to allow the tests to use the same VCR cassettes
      Sidekiq::Testing.inline! do
        VCR.use_cassette('create_repo') do
          CreateGithubWebhookJob.perform_async(@build.id)
        end
      end
    end

    after(:all) do
      @repo.reload
      directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
      FileUtils.remove_dir(directory)

      VCR.use_cassette('delete_github_webhook_for_create') do
        client = Octokit::Client.new(access_token: @repo.token)
        client.remove_hook("#{@repo.author.github_username}/#{@repo.name}", 436_611_979)
      end
    end

    it "creates an associated Build with action 'create'" do
      expect(@build.action).to eq('create')
    end

    it 'creates the first log' do
      expect(@build.logs.first.content).to eq('GitHub webhook successfully created. Now testing...')
    end

    it 'creates the second log' do
      expect(@build.logs.second.content).to eq('GitHub webhook successfully tested.')
    end

    it 'creates the third log' do
      expect(@build.logs.third.content).to eq('Repository successfully cloned.')
    end

    it 'creates the fourth log' do
      expect(@build.logs.fourth.content).to eq('Repository description successfully updated from GitHub.')
    end

    it 'with fifth log' do
      expect(@build.logs.fifth.content).to eq('Questions successfully parsed.')
    end

    it 'creates the sixth log' do
      expect(@build.logs[5].content).to eq('index.md file successfully generated.')
    end

    it "sets Build status to 'Complete'" do
      @build.reload
      expect(@build.status).to eq('Complete')
    end
  end
end
