require 'rails_helper'

RSpec.describe 'Collections #show', type: :system do
  before(:all) do
    # Clone the GitHub repo containing the required files
    @repo = create(:repository, :real, name: 'markdown-templates')
    Sidekiq::Testing.inline! do
      VCR.use_cassette('clone_github_repo_for_collections') do
        CloneGithubRepoJob.perform_async(@repo.id)
      end
    end
  end
  context 'repository is set to banned = false' do
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
      assert_selector 'h1', text: 'Non anser honore ornique'
      assert_selector 'p', text: 'Written by The Author on 2023-12-31'
    end
  end

  context 'repository is set to banned = true' do
    before do
      @repo.update(banned: true)
    end

    scenario 'displays an error page' do
      visit '/collections/jp524/markdown-templates/pages/chapter-1/chapter-1-article-1'

      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end
end
