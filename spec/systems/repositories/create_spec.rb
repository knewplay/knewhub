require 'rails_helper'

RSpec.describe 'create repository', type: :system do
  scenario 'empty name' do
    visit root_path
    click_button 'Login with GitHub'
    visit new_repository_path
    before_count = Repository.count
    assert_selector 'h1', text: 'New Repository'

    click_on 'Create Repository'

    expect(page).to have_content("Name can't be blank")
    expect(Repository.count).to eq(before_count)
  end

  scenario 'valid name and token, but no branch' do
    visit root_path
    click_button 'Login with GitHub'
    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    fill_in('Repository name', with: 'name')
    fill_in('Personal access token (required to be notified of changes to repo)', with: 'ghp_abde12345')
    click_on 'Create Repository'

    expect(page).to have_content('Home')
    expect(Repository.last.git_url).to eq('https://ghp_abde12345@github.com/some_user/name.git')
    expect(Repository.last.token).to eq('ghp_abde12345')
    expect(Repository.last.branch).to eq('main')
  end

  scenario 'valid owner, name, token and branch' do
    visit root_path
    click_button 'Login with GitHub'
    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    fill_in('Repository name', with: 'name')
    fill_in('Personal access token (required to be notified of changes to repo)', with: 'ghp_abde12345')
    fill_in('Branch (if other than main)', with: 'some_branch')
    click_on 'Create Repository'

    expect(page).to have_content('Home')
    expect(Repository.last.git_url).to eq('https://ghp_abde12345@github.com/some_user/name.git')
    expect(Repository.last.token).to eq('ghp_abde12345')
    expect(Repository.last.branch).to eq('some_branch')
  end
end
