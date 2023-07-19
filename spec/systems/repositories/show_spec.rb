require 'rails_helper'

RSpec.describe 'show repository', type: :system do
  scenario 'displays Markdown text in HTML' do
    visit '/books/jp524/markdown-templates/chapter-1/chapter-1-article-1.md'

    assert_selector 'h1', text: 'Non anser honore ornique'
  end

  scenario 'displays embedded images' do
    visit '/books/jp524/markdown-templates/chapter-1/chapter-1-article-1.md'
    expect(page).to have_css("img[alt='Ruby on Rails logo']")
  end

  scenario 'displays embedded code files' do
    visit '/books/jp524/markdown-templates/chapter-2/chapter-2-article-1.md'

    assert_selector 'p', text: 'File: ./code-files/code-example.c'
    assert_selector 'code', text: "void main() {\n  hello world\n}"
  end
end
