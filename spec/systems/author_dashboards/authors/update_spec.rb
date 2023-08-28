require 'rails_helper'
require 'support/omniauth'

RSpec.describe 'Update name as an author', type: :system do
  xscenario 'succeeds when given a valid name' do
    visit root_path
    click_on 'Login with GitHub'
    @author = Author.last
    # Author created upon calling the mock auth with 'Login with GitHub'

    expect(page).to have_content("Author: #{@author.github_username}")
    click_on 'Edit name'
    expect(page).to have_content("Edit Author ##{@author.id}")

    fill_in('Name', with: 'a-new-name')
    click_on 'Update Author'

    expect(page).to have_content('Author was successfully updated.')
    expect(page).to have_content('a-new-name')
  end

  xscenario 'fails when given an invalid name' do
    visit root_path
    click_on 'Login with GitHub'
    @author = Author.last

    expect(page).to have_content("Author: #{@author.github_username}")
    click_on 'Edit name'
    expect(page).to have_content("Edit Author ##{@author.id}")

    fill_in('Name', with: 'invalid_name')
    click_on 'Update Author'

    expect(page).to have_content('Name can only contain alphanumeric characters and dashes')
  end
end
