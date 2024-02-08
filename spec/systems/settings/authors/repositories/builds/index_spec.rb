require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories::Builds#index', type: :system do
  let(:log) { create(:log) }
  let(:build) { log.build }
  let(:repo) { build.repository }
  let(:author) { repo.author }

  context 'when logged in as an author' do
    it 'displays build information' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit settings_author_repository_builds_path(repo.id)
      expect(page).to have_content("Repository '#{repo.title}'")
      expect(page).to have_content("Action: #{build.action}")
      expect(page).to have_content(build.status)
    end

    it 'displays logs content' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit settings_author_repository_builds_path(repo.id)
      expect(page).to have_content(log.content)
    end
  end

  context 'when not logged in as an author' do
    it 'redirects to root path' do
      visit settings_author_repository_builds_path(repo.id)

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Please link your GitHub account.')
    end
  end
end
