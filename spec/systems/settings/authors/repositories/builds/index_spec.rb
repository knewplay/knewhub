require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories::Builds#index', type: :system do
  let(:log) { create(:log) }
  let(:build) { log.build }
  let(:repo) { build.repository }
  let(:author) { repo.author }

  context 'when logged in as an author' do
    scenario 'displays build information' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit settings_author_repository_builds_path(build.id)
      expect(page).to have_content("Repository '#{repo.title}'")
      expect(page).to have_content("Action: #{build.action}")
      expect(page).to have_content(build.status)
    end

    scenario 'displays logs content' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit settings_author_repository_builds_path(build.id)
      expect(page).to have_content(log.content)
    end

    scenario 'updates the log tally' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit settings_author_repository_builds_path(build.id)
      expect(page).to have_content("In progress (1/#{build.max_log_count})")
    end
  end

  context 'when not logged in as an author' do
    scenario 'redirects to root path' do
      visit settings_author_repository_builds_path(build.id)

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Please log in with GitHub.')
    end
  end
end
