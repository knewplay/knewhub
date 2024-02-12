require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories#destroy', type: :system do
  before(:all) do
    @repo = create(:repository, :real, hook_id: 440_848_647)
    @directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.mkdir_p(@directory)

    @before_count = Repository.count
    sign_in @repo.author.user

    visit edit_settings_author_repository_path(@repo.id)

    Sidekiq::Testing.inline! do
      VCR.use_cassette('remove_repo') do
        click_on 'Delete Repository'
      end
    end
  end

  it 'removes the record' do
    expect(Repository.count).to eq(@before_count - 1)
  end

  it 'removes the local directory' do
    expect(Dir.exist?(@directory)).to be(false)
  end
end
