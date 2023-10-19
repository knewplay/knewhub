require 'rails_helper'

RSpec.describe 'Collections#index', type: :system do
  before(:all) do
    @repo = create(:repository, name: 'markdown-templates')
    destination_directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    source_directory = Rails.root.join('spec/fixtures/systems/collections')
    FileUtils.mkdir_p(destination_directory)
    FileUtils.copy_entry(source_directory, destination_directory)
  end

  context 'repository is set to banned = false' do
    before do
      sign_in @repo.author.user
    end

    scenario 'displays Markdown text in HTML' do
      visit '/collections/user/markdown-templates/pages/index'

      expect(page).to have_content('Course Name')
    end

    scenario 'displays links to other pages' do
      visit '/collections/user/markdown-templates/pages/index'

      expect(page).to have_link(href: './chapter-1/chapter-1-article-1')
    end

    scenario 'displays front matter' do
      visit '/collections/user/markdown-templates/pages/index'
      expect(page).to have_content('Course Name')
      expect(page).to have_content('Written by The Author on 2023-12-31')
    end
  end

  context 'repository is set to banned = true' do
    before do
      @repo.update(banned: true)
      sign_in @repo.author.user
    end

    scenario 'displays an error page' do
      visit '/collections/user/markdown-templates/pages/index'

      expect(page).to have_content('404')
    end
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author.github_username)
    FileUtils.remove_dir(parent_directory)
  end
end
