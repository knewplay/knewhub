require 'rails_helper'

RSpec.describe 'Sessions::Administrators#destroy', type: :system do
  before(:all) do
    @admin = Administrator.create(name: 'admin', password: 'password')
    WebauthnCredential.create(
      administrator_id: @admin.id,
      external_id: 'id',
      public_key: 'key',
      nickname: 'nickname',
      sign_count: 1
    )
  end

  scenario 'logout' do
    page.set_rack_session(administrator_id: @admin.id)

    visit dashboard_root_path
    expect(page).to have_content("Admin: #{@admin.name}")
    click_on 'Logout'

    expect(page).to have_current_path(root_path)
  end
end
