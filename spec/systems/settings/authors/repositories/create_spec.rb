require 'rails_helper'

RSpec.shared_context 'when creating a new repository' do
  let!(:github_installation) { create(:github_installation) }
  let!(:author) { github_installation.author }

  before do
    sign_in author.user
    allow(author).to receive(:repositories_available_for_addition)
                 .and_return([{ full_name: 'repo_owner/repo_name', uid: 123_456_789 }])
    visit new_settings_author_repository_path(full_name: 'repo_owner/repo_name', uid: 123_456_789)
  end
end

RSpec.describe 'Settings::Authors::Repositories#create', type: :system do
  context 'when the author is allowed to add this repository' do
    context 'without using the Build process' do
      include_context 'when creating a new repository'

      it 'displays the name and owner' do
        expect(page).to have_content('New repository')

        expect(page).to have_content('Name: repo_name')
        expect(page).to have_content('Owner: repo_owner')
      end

      context 'when given a valid title but no branch' do
        it "creates the repository with default branch 'main" do
          fill_in('Title', with: 'Test Repo')

          click_on 'Create Repository'

          expect(page).to have_content('Repository creation process was initiated.')
          repo = Repository.last
          expect(repo.title).to eq('Test Repo')
          expect(repo.branch).to eq('main')
          expect(repo.full_name).to eq('repo_owner/repo_name')
          expect(repo.uid).to eq(123_456_789)
        end
      end

      context 'when given a valid title and branch' do
        it 'creates the repository' do
          fill_in('Title', with: 'Test Repo')
          fill_in('Branch', with: 'some_branch')

          click_on 'Create Repository'

          expect(page).to have_content('Repository creation process was initiated.')
          repo = Repository.last
          expect(repo.title).to eq('Test Repo')
          expect(repo.branch).to eq('some_branch')
          expect(repo.full_name).to eq('repo_owner/repo_name')
          expect(repo.uid).to eq(123_456_789)
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

    context 'when using the Build process' do
      before(:all) do
        # HTTP request required to clone repository using Octokit client
        VCR.turn_off!
        WebMock.allow_net_connect!
        author = create(:author, :real)
        github_installation = create(:github_installation, :real, author:)
        sign_in author.user

        visit new_settings_author_repository_path(full_name: 'jp524/test-repo', uid: 663_068_537)

        fill_in('Title', with: 'Test Repo')

        Sidekiq::Testing.inline! do
          click_on 'Create Repository'
        end

        @repo = github_installation.repositories.last
        @build = @repo.builds.first
      end

      after(:all) do
        @repo.reload
        FileUtils.remove_dir(@repo.storage_path)
        VCR.turn_on!
        WebMock.disable_net_connect!
      end

      it 'creates a Repository' do
        expect(@repo.full_name).to eq('jp524/test-repo')
        expect(@repo.uid).to eq(663_068_537)
      end

      it "creates an associated Build with action 'create'" do
        expect(@build.action).to eq('create')
      end

      it 'creates the first log' do
        expect(@build.logs.first.content).to eq('Repository successfully cloned.')
      end

      it 'creates the second log' do
        expect(@build.logs.second.content).to eq('Repository description successfully updated from GitHub.')
      end

      it 'with third log' do
        expect(@build.logs.third.content).to eq('Questions successfully parsed.')
      end

      it 'creates the fourth log' do
        expect(@build.logs.fourth.content).to eq('index.md file successfully generated.')
      end

      it 'creates the fifth log' do
        expect(@build.logs.fifth.content).to eq('No Autodesk files were found in this repository.')
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
      allow(author).to receive(:repositories_available_for_addition)
                   .and_return([{ full_name: 'author/repository', uid: 987_654_321 }])
      visit new_settings_author_repository_path(full_name: 'author/repo_name', uid: 123_456_789)
    end

    it 'redirects to root path and displays an alert' do
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('You are not have permission to add this repository.')
    end
  end
end
