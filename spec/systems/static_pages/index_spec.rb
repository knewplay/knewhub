require 'rails_helper'

RSpec.describe 'StaticPages#index', type: :system do
  it 'introduces KnewHub and links to every learning path' do
    visit root_path

    expect(page).to have_content('Learn how to think in code.')
    expect(page).to have_link(
      'Programming Essentials',
      href: '/collections/andreigue/andreigue/book-programming-essential/pages/index'
    )
    expect(page).to have_link(
      'VEX 123 for Parents',
      href: '/collections/andreigue/andreigue/vex-123-for-parents/pages/index'
    )
    expect(page).to have_link(
      'OOP Fundamentals',
      href: '/collections/andreigue/andreigue/oop-fundamentals/pages/index'
    )
    expect(page).to have_link(
      'Apply to become a creator',
      href: 'mailto:apply@knewhub.com?subject=KnewHub%20content%20creator%20application'
    )
  end
end
