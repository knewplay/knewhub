require 'rails_helper'

RSpec.describe 'Collections#index', type: :system do
  before(:all) do
    @repo = create(:repository, name: 'markdown-templates')
    destination_directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    source_directory = Rails.root.join('spec/fixtures/systems/collections')
    FileUtils.mkdir_p(destination_directory)
    FileUtils.copy_entry(source_directory, destination_directory)
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author.github_username)
    FileUtils.remove_dir(parent_directory)
  end

  context 'when repository is set to banned = false' do
    before do
      sign_in @repo.author.user
    end

    context 'when repository build state is Complete' do
      before do
        create(:build, repository: @repo, aasm_state: :completed, status: 'Complete')
      end

      it 'displays Markdown text in HTML' do
        visit '/collections/user/markdown-templates/pages/index'

        expect(page).to have_content('Course Name')
      end

      it 'displays links to other pages' do
        visit '/collections/user/markdown-templates/pages/index'

        expect(page).to have_link(href: './chapter-1/chapter-1-article-1')
      end

      it 'displays front matter' do
        visit '/collections/user/markdown-templates/pages/index'
        expect(page).to have_content('Course Name')
        expect(page).to have_content('Written by The Author on 2023-12-31')
      end

      it 'does not render content from an HTML file with the same name' do
        visit '/collections/user/markdown-templates/pages/index'
        expect(page).to have_no_content('Content from HTML file')
      end
    end

    context 'when repository build state is not Complete' do
      before do
        sign_in @repo.author.user
        create(:build, repository: @repo, aasm_state: :cloning_repo, status: 'In progress')
      end

      it 'displays an error page' do
        visit '/collections/user/markdown-templates/pages/index'

        expect(page).to have_content('404')
      end
    end
  end

  context 'when repository is set to banned = true' do
    before do
      @repo.update(banned: true)
      sign_in @repo.author.user
    end

    it 'displays an error page' do
      visit '/collections/user/markdown-templates/pages/index'

      expect(page).to have_content('404')
    end
  end
end
