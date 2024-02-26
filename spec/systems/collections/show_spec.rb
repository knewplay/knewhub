require 'rails_helper'

RSpec.describe 'Collections#show', type: :system do
  before(:all) do
    @repo = create(:repository, name: 'markdown-templates')
    destination_directory = @repo.storage_path
    source_directory = Rails.root.join('spec/fixtures/systems/collections')
    FileUtils.mkdir_p(destination_directory)
    FileUtils.copy_entry(source_directory, destination_directory)

    parse_questions_build = create(:build, repository: @repo, aasm_state: :parsing_questions)
    Sidekiq::Testing.inline! do
      ParseQuestionsJob.perform_async(parse_questions_build.id)
    end
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author_username)
    FileUtils.remove_dir(parent_directory)
  end

  context 'when repository is set to banned = false' do
    before do
      sign_in @repo.author.user
    end

    it 'displays Markdown text in HTML' do
      visit '/collections/author/repo_owner/markdown-templates/pages/chapter-1/chapter-1-article-1'

      assert_selector 'h2', text: 'Amplectitur atque mutabile'
    end

    it 'displays embedded images' do
      visit '/collections/author/repo_owner/markdown-templates/pages/chapter-1/chapter-1-article-1'
      expect(page).to have_css("img[alt='Ruby on Rails logo']")
    end

    it 'displays embedded code files' do
      visit '/collections/author/repo_owner/markdown-templates/pages/chapter-2/chapter-2-article-1'

      assert_selector 'p', text: 'File: ./code-files/code-example.c'
      assert_selector 'code', text: "void main() {\n  hello world\n}"
    end

    it 'displays front matter' do
      visit '/collections/author/repo_owner/markdown-templates/pages/chapter-1/chapter-1-article-1'
      expect(page).to have_content('Non anser honore ornique')
      expect(page).to have_content('Written by The Author on 2023-12-31')
    end

    it 'does not render content from an HTML file with the same name' do
      visit '/collections/author/repo_owner/markdown-templates/pages/chapter-2/chapter-2-article-2'
      expect(page).to have_no_content('Content from HTML file')
    end

    context 'when page has questions in front-matter' do
      it 'displays the questions associated with an article' do
        visit '/collections/author/repo_owner/markdown-templates/pages/chapter-1/chapter-1-article-1'

        expect(page).to have_content('First question in article one?')
        expect(page).to have_content('Second question in article one?')
      end

      it 'does not display questions associated with other articles' do
        visit '/collections/author/repo_owner/markdown-templates/pages/chapter-1/chapter-1-article-1'

        expect(page).to have_no_content('First question in article two?')
        expect(page).to have_no_content('Second question in article two?')
      end
    end

    context 'when page does not have questions in front-matter' do
      it 'does not show the Questions header' do
        visit '/collections/author/repo_owner/markdown-templates/pages/chapter-2/chapter-2-article-1'

        expect(page).to have_no_content('Questions')
      end
    end

    context 'when marp == true in front-matter' do
      before do
        visit '/collections/author/repo_owner/markdown-templates/pages/chapter-3/marp-slides'
      end

      it 'parses content as slides' do
        assert_selector 'swiper-container'
        assert_selector 'swiper-slide'
      end

      it 'displays Markdown text in HTML' do
        assert_selector 'h1', text: 'Hello, Marpit!'
      end

      it 'displays embedded images' do
        expect(page).to have_css("img[alt='Ruby on Rails logo']")
      end

      it 'displays front-matter' do
        expect(page).to have_content('Marp Slides')
        expect(page).to have_content('Written by The Author on 2023-12-31')
      end
    end
  end

  context 'when repository is set to banned = true' do
    before do
      @repo.update(banned: true)
      sign_in @repo.author.user
    end

    it 'displays an error page' do
      visit '/collections/author/repo_owner/markdown-templates/pages/chapter-1/chapter-1-article-1'

      expect(page).to have_content('404')
    end
  end
end
