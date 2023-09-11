require 'rails_helper'

RSpec.describe 'AuthorSpace::Repositories #update', type: :system do
  let(:repo) { create(:repository) }
  let(:author) { repo.author }

  context 'when given valid input' do
    scenario 'updates the name' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit edit_settings_author_repository_path(repo.id)
      expect(page).to have_content("Edit Repository ##{repo.id}")

      fill_in('Name', with: 'a_new_name')
      click_on 'Update Repository'

      expect(page).to have_content('Repository was successfully updated.')
      expect(page).to have_content('a_new_name')

      repo.reload
      expect(repo.git_url).to eq('https://ghp_abcde12345@github.com/user/a_new_name.git')
    end

    scenario 'updates the branch' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit edit_settings_author_repository_path(repo.id)
      expect(page).to have_content("Edit Repository ##{repo.id}")

      fill_in('Branch', with: 'other_branch')
      click_on 'Update Repository'

      expect(page).to have_content('Repository was successfully updated.')

      repo.reload
      expect(repo.branch).to eq('other_branch')
    end
  end

  context 'when given invalid input' do
    scenario 'fails to update' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit edit_settings_author_repository_path(repo.id)
      expect(page).to have_content("Edit Repository ##{repo.id}")

      fill_in('Branch', with: 'invalid!branch')
      click_on 'Update Repository'

      expect(page).to have_content('Branch must follow GitHub branch name restrictions')
    end
  end
end
