require 'rails_helper'

RSpec.describe 'index collection', type: :system do
  scenario 'displays Markdown text in HTML' do
    visit '/collections/jp524/markdown-templates/pages/index'

    assert_selector 'h1', text: 'Course Name'
  end

  scenario 'displays links to other pages' do
    visit '/collections/jp524/markdown-templates/pages/index'

    expect(page).to have_link(href: './chapter-1/chapter-1-article-1')
  end
end
