require 'rails_helper'

RSpec.describe 'AuthorSpace::Repositories#create', type: :system do
  let(:author) { create(:author) }

  context 'when given valid name and token, but no branch' do 
    scenario 'creates the repository' do
      page.set_rack_session(author_id: author.id)
      visit new_author_repository_path
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
      page.set_rack_session(author_id: author.id)
      visit new_author_repository_path
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
      page.set_rack_session(author_id: author.id)
      visit new_author_repository_path
      expect(page).to have_content('New Repository')

      fill_in('Name', with: 'repo_name')
      fill_in('Title', with: 'Test Repo')
      fill_in('Token', with: 'abcde12345')
      click_on 'Create Repository'

      expect(page).to have_content('Token must start with "github_pat" or "ghp"')
    end
  end
end
