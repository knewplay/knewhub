require 'rails_helper'

RSpec.describe 'Answers#create', type: :system do
  let(:user) { create(:user, :second) }
  let(:question) { create(:question) }

  context 'when logged in as a user' do
    context 'when given valid content' do
      scenario 'creates a new answer' do
        sign_in user
        visit new_answer_path(question.id)
        expect(page).to have_content('New answer')

        fill_in('Your answer...', with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
        click_on 'Create Answer'

        visit answers_path(question.id)
        expect(page).to have_content('Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
      end
    end

    context 'when given no content' do
      scenario 'it displays an error message' do
        sign_in user
        visit new_answer_path(question.id)
        expect(page).to have_content('New answer')

        click_on 'Create Answer'

        message = page.find('#answer_body').native.attribute('validationMessage')
        expect(message).to eq 'Please fill out this field.'
      end
    end
  end

  context 'when not logged in as a user' do
    scenario 'it redirects to login page' do
      visit new_answer_path(question.id)

      expect(page).to have_content('You need to log in or create an account before continuing.')
    end
  end
end
