require 'rails_helper'

RSpec.describe 'update name as an author', type: :system do
  before(:all) do
    @author = Author.create(github_uid: '123545', github_username: 'some-user')
  end

  scenario 'succeeds when given a valid name' do
    visit root_path
    click_button 'Login with GitHub'

    expect(page).to have_content("Author: #{@author.github_username}")
    click_on 'Edit name'
    expect(page).to have_content("Edit Author ##{@author.id}")

    fill_in('Name', with: 'a-new-name')
    click_on 'Update Author'

    expect(page).to have_content('Author was successfully updated.')
    expect(page).to have_content('a-new-name')
  end

  scenario 'fails when given an invalid name' do
    visit root_path
    click_button 'Login with GitHub'

    expect(page).to have_content("Author: #{@author.github_username}")
    click_on 'Edit name'
    expect(page).to have_content("Edit Author ##{@author.id}")

    fill_in('Name', with: 'invalid_name')
    click_on 'Update Author'

    expect(page).to have_content('Name can only contain alphanumeric characters and dashes')
  end
end