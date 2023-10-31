require 'rails_helper'

RSpec.shared_context 'when creating a new answer' do
  before do
    sign_in user
    visit new_answer_path(question.id)
  end
end

RSpec.describe Answer, '#create', type: :system do
  let(:user) { create(:user, :second) }
  let(:question) { create(:question) }

  context 'when logged in as a user' do
    include_context 'when creating a new answer'

    context 'when given valid content' do
      it 'creates a new answer' do
        fill_in('Your answer...', with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
        click_on 'Create Answer'

        visit answers_path(question.id)
        expect(page).to have_content('Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
      end
    end

    context 'when given no content' do
      it 'displays an error message' do
        click_on 'Create Answer'

        message = page.find('#answer_body').native.attribute('validationMessage')
        expect(message).to eq 'Please fill out this field.'
      end
    end
  end

  context 'when not logged in as a user' do
    it 'redirects to login page' do
      visit new_answer_path(question.id)

      expect(page).to have_content('You need to log in or create an account before continuing.')
    end
  end
end
