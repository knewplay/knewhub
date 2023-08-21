require 'rails_helper'

RSpec.describe 'Collections #index', type: :system do
  before(:all) do
    # Clone the GitHub repo containing the required files
    @repo = create(:repository, :real, name: 'markdown-templates')
    Sidekiq::Testing.inline! do
      VCR.use_cassette('clone_github_repo_for_collections') do
        CloneGithubRepoJob.perform_async(@repo.id)
      end
    end
  end

  scenario 'displays Markdown text in HTML' do
    visit '/collections/jp524/markdown-templates/pages/index'

    assert_selector 'h1', text: 'Course Name'
  end

  scenario 'displays links to other pages' do
    visit '/collections/jp524/markdown-templates/pages/index'

    expect(page).to have_link(href: './chapter-1/chapter-1-article-1')
  end

  scenario 'displays front matter' do
    visit '/collections/jp524/markdown-templates/pages/index'
    assert_selector 'h1', text: 'Course Name'
    assert_selector 'p', text: 'Written by The Author on 2023-12-31'
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end
end
