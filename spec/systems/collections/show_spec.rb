require 'rails_helper'

RSpec.describe 'Collections#show', type: :system do
  before(:all) do
    @repo = create(:repository)
    destination_directory = @repo.storage_path
    source_directory = Rails.root.join('spec/fixtures/systems/collections')
    FileUtils.mkdir_p(destination_directory)
    FileUtils.copy_entry(source_directory, destination_directory)

    parse_questions_build = create(:build, repository: @repo, aasm_state: :parsing_questions)
    Sidekiq::Testing.inline! do
      # Cassettes required for UploadAutodeskFilesJob taking place after ParseQuestionsJob
      VCR.use_cassettes(
        [{ name: 'get_autodesk_access_token', options: { allow_playback_repeats: true } },
         { name: 'upload_3d_file_autodesk_additional' },
         { name: 'upload_3d_file_autodesk' }]
      ) do
        ParseQuestionsJob.perform_async(parse_questions_build.id)
      end
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
      visit '/collections/author/repo_owner/repo_name/pages/chapter-1/chapter-1-article-1'

      assert_selector 'h2', text: 'Amplectitur atque mutabile'
    end

    it 'displays embedded images' do
      visit '/collections/author/repo_owner/repo_name/pages/chapter-1/chapter-1-article-1'
      expect(page).to have_css("img[alt='Ruby on Rails logo']")
    end

    it 'displays embedded code files' do
      visit '/collections/author/repo_owner/repo_name/pages/chapter-2/chapter-2-article-1'

      assert_selector 'code'
      assert_selector 'pre', class: 'c'
      assert_selector 'span', text: 'void'
      assert_selector 'span', text: 'main'
    end

    it 'displays embedded code gists' do
      visit '/collections/author/repo_owner/repo_name/pages/chapter-2/chapter-2-article-1'

      expect(page).to have_css(
        "script[src='https://gist.github.com/jp524/2d00cbf0a9976db406e4369b31e25460.js']",
        visible: :hidden
      )
      assert_selector 'div', class: 'gist'
      assert_selector 'a', text: 'test.rb'
    end

    context 'with Autodesk viewer:' do
      before do
        VCR.insert_cassette('autodesk_viewer', record: :new_episodes)
      end

      after do
        VCR.eject_cassette
      end

      it 'displays embedded Autodesk viewer for 3D files' do
        visit '/collections/author/repo_owner/repo_name/pages/chapter-2/chapter-2-article-2'

        expect(page).to have_css(
          "script[src='https://developer.api.autodesk.com/modelderivative/v2/viewers/7.*/viewer3D.min.js']",
          visible: :hidden
        )
      end
    end

    it 'displays front matter' do
      visit '/collections/author/repo_owner/repo_name/pages/chapter-1/chapter-1-article-1'
      expect(page).to have_content('Non anser honore ornique')
      expect(page).to have_content('Written by The Author on 2023-12-31')
    end

    context 'with Autodesk viewer' do
      before do
        VCR.insert_cassette('autodesk_viewer', record: :new_episodes)
      end

      after do
        VCR.eject_cassette
      end

      it 'does not render content from an HTML file with the same name' do
        VCR.use_cassette('autodesk-viewer') do
          visit '/collections/author/repo_owner/repo_name/pages/chapter-2/chapter-2-article-2'
          expect(page).to have_no_content('Content from HTML file')
        end
      end
    end

    context 'when page has questions in front-matter' do
      it 'displays the questions associated with an article' do
        visit '/collections/author/repo_owner/repo_name/pages/chapter-1/chapter-1-article-1'

        expect(page).to have_content('First question in article one?')
        expect(page).to have_content('Second question in article one?')
      end

      it 'does not display questions associated with other articles' do
        visit '/collections/author/repo_owner/repo_name/pages/chapter-1/chapter-1-article-1'

        expect(page).to have_no_content('First question in article two?')
        expect(page).to have_no_content('Second question in article two?')
      end
    end

    context 'when page does not have questions in front-matter' do
      it 'does not show the Questions header' do
        visit '/collections/author/repo_owner/repo_name/pages/chapter-2/chapter-2-article-1'

        expect(page).to have_no_content('Questions')
      end
    end

    context 'when marp == true in front-matter' do
      before do
        visit '/collections/author/repo_owner/repo_name/pages/chapter-3/marp-slides'
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
      visit '/collections/author/repo_owner/repo_name/pages/chapter-1/chapter-1-article-1'

      expect(page).to have_content('404')
    end
  end
end
