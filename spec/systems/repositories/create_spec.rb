require 'rails_helper'

RSpec.describe 'create repository', type: :system do
  scenario 'empty owner and name' do
    expect(Repository.count).to eq(0)

    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    click_on 'Create Repository'

    expect(page).to have_content("Owner can't be blank")
    expect(Repository.count).to eq(0)
  end

  scenario 'valid owner and name, no token, no branch' do
    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    fill_in('Repository owner', with: 'owner')
    fill_in('Repository name', with: 'name')
    click_on 'Create Repository'

    expect(page).to have_content('Home')
    expect(Repository.last.git_url).to eq('https://github.com/owner/name.git')
    expect(Repository.last.token).to eq('')
    expect(Repository.last.branch).to eq('main')
  end

  scenario 'valid owner, name, token and branch' do
    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    fill_in('Repository owner', with: 'owner')
    fill_in('Repository name', with: 'name')
    fill_in('Personal access token (if repository is private)', with: 'ghp_abde12345')
    fill_in('Branch (if other than main)', with: 'some_branch')
    click_on 'Create Repository'

    expect(page).to have_content('Home')
    expect(Repository.last.git_url).to eq('https://ghp_abde12345@github.com/owner/name.git')
    expect(Repository.last.token).to eq('ghp_abde12345')
    expect(Repository.last.branch).to eq('some_branch')
  end
end
