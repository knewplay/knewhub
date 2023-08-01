require 'rails_helper'

RSpec.describe 'update repository as an author', type: :system do
  before(:all) do
    author = Author.create(github_uid: '123545', github_username: 'some_user')
    @repo = Repository.create(name: 'repo_name', token: 'ghp_abde12345', author:)
  end

  scenario 'change name of repository' do
    expect(@repo.git_url).to eq('https://ghp_abde12345@github.com/some_user/repo_name.git')

    visit root_path
    click_button 'Login with GitHub'
    expect(page).to have_content('Repositories')
    expect(page).to have_content('repo_name')

    click_on 'Edit'
    expect(page).to have_content("Edit Repository ##{@repo.id}")

    fill_in('Name', with: 'a_new_name')
    click_on 'Update Repository'

    expect(page).to have_content('Repository was successfully updated.')
    expect(page).to have_content('a_new_name')

    @repo.reload
    expect(@repo.git_url).to eq('https://ghp_abde12345@github.com/some_user/a_new_name.git')
  end

  scenario 'change branch of repository' do
    expect(@repo.git_url).to eq('https://ghp_abde12345@github.com/some_user/a_new_name.git')

    visit root_path
    click_button 'Login with GitHub'
    expect(page).to have_content('Repositories')
    expect(page).to have_content('main')

    click_on 'Edit'
    expect(page).to have_content("Edit Repository ##{@repo.id}")

    fill_in('Branch', with: 'other_branch')
    click_on 'Update Repository'

    expect(page).to have_content('Repository was successfully updated.')
    expect(page).to have_content('other_branch')
  end
end
