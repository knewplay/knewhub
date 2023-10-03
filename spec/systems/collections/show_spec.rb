require 'rails_helper'

RSpec.describe 'Collections#show', type: :system do
  before(:all) do
    # Clone the GitHub repo containing the required files
    @repo = create(:repository, :real, name: 'markdown-templates')
    build = create(:build, repository: @repo)
    Sidekiq::Testing.inline! do
      VCR.use_cassette('clone_github_repo_for_collections') do
        CloneGithubRepoJob.perform_async(@repo.id, build.id)
      end
      ParseQuestionsJob.perform_async(@repo.id, build.id)
    end
  end

  context 'repository is set to banned = false' do
    before do
      sign_in @repo.author.user
    end

    scenario 'displays Markdown text in HTML' do
      visit '/collections/jp524/markdown-templates/pages/chapter-1/chapter-1-article-1'

      assert_selector 'h2', text: 'Amplectitur atque mutabile'
    end

    scenario 'displays embedded images' do
      visit '/collections/jp524/markdown-templates/pages/chapter-1/chapter-1-article-1'
      expect(page).to have_css("img[alt='Ruby on Rails logo']")
    end

    scenario 'displays embedded code files' do
      visit '/collections/jp524/markdown-templates/pages/chapter-2/chapter-2-article-1'

      assert_selector 'p', text: 'File: ./code-files/code-example.c'
      assert_selector 'code', text: "void main() {\n  hello world\n}"
    end

    scenario 'displays front matter' do
      visit '/collections/jp524/markdown-templates/pages/chapter-1/chapter-1-article-1'
      expect(page).to have_content('Non anser honore ornique')
      expect(page).to have_content('Written by The Author on 2023-12-31')
    end

    context 'when page has questions in front-matter' do
      scenario 'displays the questions associated with an article' do
        visit '/collections/jp524/markdown-templates/pages/chapter-1/chapter-1-article-1'

        expect(page).to have_content('First question in article one?')
        expect(page).to have_content('Second question in article one?')
      end

      scenario 'does not display questions associated with other articles' do
        visit '/collections/jp524/markdown-templates/pages/chapter-1/chapter-1-article-1'

        expect(page).to_not have_content('First question in article two?')
        expect(page).to_not have_content('Second question in article two?')
      end
    end

    context 'when page does not have questions in front-matter' do
      scenario 'does not show the Questions header' do
        visit '/collections/jp524/markdown-templates/pages/chapter-2/chapter-2-article-1'

        expect(page).to_not have_content('Questions')
      end
    end
  end

  context 'repository is set to banned = true' do
    before do
      @repo.update(banned: true)
      sign_in @repo.author.user
    end

    scenario 'displays an error page' do
      visit '/collections/jp524/markdown-templates/pages/chapter-1/chapter-1-article-1'

      expect(page).to have_content('404')
    end
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end
end
