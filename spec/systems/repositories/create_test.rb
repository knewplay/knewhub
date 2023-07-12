require 'rails_helper'

RSpec.describe 'create repository', type: :system do
  scenario 'empty owner and name' do
    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    click_on 'Create Repository'

    expect(page).to have_content("Owner can't be blank")
    expect(Repository.count).to eq(0)
  end

  scenario 'valid owner and name, no token' do
    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    fill_in('Repository owner', with: 'owner')
    fill_in('Repository name', with: 'name')
    click_on 'Create Repository'

    expect(Repository.first.git_url).to eq('https://github.com/owner/name.git')
    expect(Repository.first.token).to eq('')
  end

  scenario 'valid owner, name and token' do
    visit new_repository_path
    assert_selector 'h1', text: 'New Repository'

    fill_in('Repository owner', with: 'owner')
    fill_in('Repository name', with: 'name')
    fill_in('Personal access token (if repository is private)', with: 'ghp_abde12345')
    click_on 'Create Repository'

    expect(Repository.first.git_url).to eq('https://ghp_abde12345@github.com/owner/name.git')
    expect(Repository.first.token).to eq('ghp_abde12345')
  end
end
