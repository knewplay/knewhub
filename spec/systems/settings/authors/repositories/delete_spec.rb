require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories#destroy', type: :system do
  before(:all) do
    @repo = create(:repository, :real, hook_id: 436760769)
    @directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.mkdir_p(@directory)

    @before_count = Repository.all.count
    sign_in @repo.author.user
    page.set_rack_session(author_id: @repo.author.id)

    visit edit_settings_author_repository_path(@repo.id)

    Sidekiq::Testing.inline! do
      VCR.use_cassette('remove_repo') do
        click_button 'Delete Repository'
      end
    end
  end

  scenario 'removes the record' do
    expect(Repository.all.count).to eq(@before_count - 1)
  end

  scenario 'removes the local directory' do
    expect(Dir.exist?(@directory)).to be(false)
  end
end
