require 'rails_helper'

RSpec.describe 'Update repository as an author', type: :system do
  before(:each) do
    @repo = create(:repository)
  end

  scenario 'to change name' do
    page.set_rack_session(author_id: @repo.author.id)

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
    page.set_rack_session(author_id: @repo.author.id)

    visit author_dashboards_repository_path(@repo.id)
    expect(page).to have_content('main')
    click_on "Edit Repository ##{@repo.id}"

    fill_in('Branch', with: 'other_branch')
    click_on 'Update Repository'

    expect(page).to have_content('Repository was successfully updated.')
    expect(page).to have_content('other_branch')
  end
end
