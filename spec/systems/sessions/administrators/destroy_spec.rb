require 'rails_helper'

RSpec.describe 'Administrator', type: :system do
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

  scenario 'sign out' do
    page.set_rack_session(administrator_id: @admin.id)

    visit system_dashboards_root_path
    expect(page).to have_content("Admin: #{@admin.name}")
    click_on 'Sign out'

    expect(page).to have_current_path(root_path)
  end
end
