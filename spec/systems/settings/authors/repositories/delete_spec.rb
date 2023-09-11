require 'rails_helper'

RSpec.describe 'Settings::AuthorSpace::Repositories#destroy', type: :system do
  before(:each) do
    @repo = create(:repository)
    @directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.mkdir_p(@directory)
  end

  scenario 'removes the record' do
    before_count = Repository.all.count
    sign_in @repo.author.user
    page.set_rack_session(author_id: @repo.author.id)

    visit edit_settings_author_repository_path(@repo.id)

    accept_alert do
      click_button 'Delete Repository'
    end

    sleep(1)
    expect(Repository.all.count).to eq(before_count - 1)
  end

  scenario 'removes the local directory' do
    sign_in @repo.author.user
    page.set_rack_session(author_id: @repo.author.id)

    visit edit_settings_author_repository_path(@repo.id)

    accept_alert do
      click_button 'Delete Repository'
    end

    sleep(1)
    expect(Dir.exist?(@directory)).to be(false)
  end
end
