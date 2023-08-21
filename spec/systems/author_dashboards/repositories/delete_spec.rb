require 'rails_helper'

RSpec.describe 'Delete repository as an author', type: :system do
  before(:each) do
    @repo = create(:repository)
    @directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.mkdir_p(@directory)
  end

  scenario 'removes the record' do
    before_count = Repository.all.count
    page.set_rack_session(author_id: @repo.author.id)

    visit author_dashboards_repository_path(@repo.id)
    expect(page).to have_content('repo_name')

    accept_alert do
      click_link 'Destroy'
    end

    sleep(1)
    expect(Repository.all.count).to eq(before_count - 1)
  end

  scenario 'removes the local directory' do
    page.set_rack_session(author_id: @repo.author.id)

    visit author_dashboards_repository_path(@repo.id)
    expect(page).to have_content('repo_name')

    accept_alert do
      click_link 'Destroy'
    end

    sleep(1)
    expect(Dir.exist?(@directory)).to be(false)
  end
end
