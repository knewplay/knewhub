require 'rails_helper'
require 'support/omniauth'

RSpec.describe 'Update repository as an author', type: :system do
  scenario 'to change name' do
    # Creation of repository done here instead of using a factory
    # because of interaction with mock auth
    before_count = Repository.count

    visit root_path
    click_on 'Login with GitHub'
    expect(page).to have_content('Repositories')

    click_on 'New repository'

    fill_in('Name', with: 'repo_name')
    fill_in('Title', with: 'Test Repo')
    fill_in('Token', with: 'ghp_abcde12345')
    click_on 'Create Repository'

    expect(Repository.count).to eq(before_count + 1)
    @repo = Repository.last
    # Creation of repository over

    expect(@repo.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')

    visit author_dashboards_repository_path(@repo.id)
    expect(page).to have_content('repo_name')
    click_on "Edit Repository ##{@repo.id}"

    expect(page).to have_content("Edit Repository ##{@repo.id}")

    fill_in('Name', with: 'a_new_name')
    click_on 'Update Repository'

    expect(page).to have_content('Repository was successfully updated.')
    expect(page).to have_content('a_new_name')

    @repo.reload
    expect(@repo.git_url).to eq('https://ghp_abcde12345@github.com/user/a_new_name.git')
  end

  scenario 'to change branch' do
    # Creation of repository done here instead of using a factory
    # because of interaction with mock auth
    before_count = Repository.count

    visit root_path
    click_on 'Login with GitHub'
    expect(page).to have_content('Repositories')

    click_on 'New repository'

    fill_in('Name', with: 'repo_name')
    fill_in('Title', with: 'Test Repo')
    fill_in('Token', with: 'ghp_abcde12345')
    click_on 'Create Repository'

    expect(Repository.count).to eq(before_count + 1)
    @repo = Repository.last
    # Creation of repository over

    expect(@repo.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')

    visit author_dashboards_repository_path(@repo.id)
    expect(page).to have_content('main')
    click_on "Edit Repository ##{@repo.id}"

    fill_in('Branch', with: 'other_branch')
    click_on 'Update Repository'

    expect(page).to have_content('Repository was successfully updated.')
    expect(page).to have_content('other_branch')
  end
end
