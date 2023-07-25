require 'rails_helper'

RSpec.describe 'show collection', type: :system do
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
