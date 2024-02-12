require 'rails_helper'

RSpec.shared_context 'when creating a new repository' do
  let(:author) { create(:author) }

  before do
    sign_in author.user
    allow(author).to receive(:repositories_available_for_addition).and_return('user/repo_name')
    visit new_settings_author_repository_path(full_name: 'user/repo_name')
  end
end

RSpec.describe 'Settings::Authors::Repositories#create', type: :system do
  context 'when the author is allowed to add this repository' do
    context 'without using the Build process' do
      include_context 'when creating a new repository'

      it 'displays the name and owner' do
        expect(page).to have_content('New repository')

        expect(page).to have_content('Name: repo_name')
        expect(page).to have_content('Owner: user')
      end

      context 'when given a valid title but no branch' do
        it "creates the repository with default branch 'main" do
          fill_in('Title', with: 'Test Repo')

          click_on 'Create Repository'

          expect(page).to have_content('Repository creation process was initiated.')
          expect(Repository.last.title).to eq('Test Repo')
          expect(Repository.last.branch).to eq('main')
        end
      end

      context 'when given a valid title and branch' do
        it 'creates the repository' do
          fill_in('Title', with: 'Test Repo')
          fill_in('Branch', with: 'some_branch')

          click_on 'Create Repository'

          expect(page).to have_content('Repository creation process was initiated.')
          expect(Repository.last.branch).to eq('some_branch')
        end
      end

      context 'when given invalid input' do
        it 'fails to create the repository' do
          fill_in('Title', with: '')
          click_on 'Create Repository'
          expect(page).to have_no_content('Repository creation process was initiated.')
          # The validation takes place using JS so the Rails backend doesn't return an error
        end
      end
    end

    context 'when using the Build process', skip: 'To be updated' do
      before(:all) do
        author = create(:author, :real)
        sign_in author.user
        page.set_rack_session(author_id: author.id)

        visit new_settings_author_repository_path

        fill_in('Repository name on GitHub', with: 'test-repo')
        fill_in('Repository title', with: 'Test Repo')
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
        directory = Rails.root.join('repos', @repo.full_name)
        FileUtils.remove_dir(directory)

        VCR.use_cassette('delete_github_webhook_for_create') do
          client = Octokit::Client.new(access_token: @repo.token)
          client.remove_hook(@repo.full_name, 436_611_979)
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

  context 'when the author is not allowed to add this repository' do
    let(:author) { create(:author) }

    before do
      sign_in author.user
      allow(author).to receive(:repositories_available_for_addition).and_return('user/repository')
      visit new_settings_author_repository_path(full_name: 'user/repo_name')
    end

    it 'redirects to root path and displays an alert' do
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('You are not have permission to add this repository.')
    end
  end
end
