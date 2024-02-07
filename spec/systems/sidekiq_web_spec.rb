require 'rails_helper'

RSpec.describe 'Sidekiq::Web', type: :system do
  context 'when logged in as an administrator' do
    let(:administrator) { create(:administrator) }

    it 'can access the Sidekiq UI' do
      page.set_rack_session(administrator_id: administrator.id)
      visit sidekiq_web_path
      expect(page).to have_content('Sidekiq')
    end
  end

  context 'when logged in as a user' do
    it 'cannot access the Sidekiq UI' do
      visit sidekiq_web_path
      expect(page).to have_content('404')
    end
  end

  context 'when not logged in as an administrator' do
    let(:user) { create(:user) }

    it 'cannot access the Sidekiq UI' do
      sign_in user
      visit sidekiq_web_path
      expect(page).to have_content('404')
    end
  end
end
