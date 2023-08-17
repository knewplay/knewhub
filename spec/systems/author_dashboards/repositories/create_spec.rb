require 'rails_helper'
require 'support/omniauth'

RSpec.describe 'Create repository as an author', type: :system do
  scenario 'with an empty name' do
    visit root_path
    click_on 'Login with GitHub'
    expect(page).to have_content('Repositories')

    click_on 'New repository'
    before_count = Repository.count

    click_on 'Create Repository'

    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Token can't be blank")
    expect(Repository.count).to eq(before_count)
  end

  scenario 'with a valid name and token, but no branch' do
    visit root_path
    click_button 'Login with GitHub'
    expect(page).to have_content('Repositories')

    click_on 'New repository'

    fill_in('Name', with: 'repo_name')
    fill_in('Title', with: 'Test Repo')
    fill_in('Token', with: 'ghp_abcde12345')
    click_on 'Create Repository'

    expect(page).to have_content('Repository was successfully created.')
    expect(Repository.last.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')
    expect(Repository.last.token).to eq('ghp_abcde12345')
    expect(Repository.last.branch).to eq('main')
  end

  scenario 'with a valid name, token and branch' do
    visit root_path
    click_on 'Login with GitHub'
    expect(page).to have_content('Repositories')

    click_on 'New repository'

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
