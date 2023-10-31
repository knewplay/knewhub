require 'rails_helper'

RSpec.describe 'User::Sessions#destroy', type: :system do
  let(:user) { create(:user) }

  it 'signs out' do
    sign_in user
    visit root_path

    click_on 'Logout'

    expect(page).to have_content('Signed out successfully.')
  end
end
