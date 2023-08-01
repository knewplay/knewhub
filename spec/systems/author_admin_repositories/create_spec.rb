require 'rails_helper'

RSpec.describe 'create repository as an author', type: :system do
  scenario 'empty name' do
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

  scenario 'valid name and token, but no branch' do
    visit root_path
    click_button 'Login with GitHub'
    expect(page).to have_content('Repositories')

    click_on 'New repository'

    fill_in('Name', with: 'name')
    fill_in('Token', with: 'ghp_abde12345')
    click_on 'Create Repository'

    expect(page).to have_content('Repository was successfully created.')
    expect(Repository.last.git_url).to eq('https://ghp_abde12345@github.com/some_user/name.git')
    expect(Repository.last.token).to eq('ghp_abde12345')
    expect(Repository.last.branch).to eq('main')
  end

  scenario 'valid owner, name, token and branch' do
    visit root_path
    click_on 'Login with GitHub'
    expect(page).to have_content('Repositories')

    click_on 'New repository'

    fill_in('Name', with: 'name')
    fill_in('Token', with: 'ghp_abde12345')
    fill_in('Branch', with: 'some_branch')
    click_on 'Create Repository'

    expect(page).to have_content('Repository was successfully created.')
    expect(Repository.last.git_url).to eq('https://ghp_abde12345@github.com/some_user/name.git')
    expect(Repository.last.token).to eq('ghp_abde12345')
    expect(Repository.last.branch).to eq('some_branch')
  end
end
