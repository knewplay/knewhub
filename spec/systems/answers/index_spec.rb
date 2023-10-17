require 'rails_helper'

RSpec.describe 'Answers#index', type: :system do
  before(:all) do
    @first_user = create(:user, email: 'email1@test.com')
    second_user = create(:user, email: 'email2@test.com')
    @question = create(:question)
    @first_answer = create(:answer, user: @first_user, question: @question, body: 'This is the first answer.')
    @second_answer = create(:answer, user: second_user, question: @question, body: 'This is the second answer.')
  end

  context 'when logged in as a user' do
    scenario 'it displays all answers associated with a question' do
      sign_in @first_user
      visit answers_path(@question.id)

      expect(page).to have_content(@question.body)
      expect(page).to have_content(@first_answer.body)
      expect(page).to have_content(@second_answer.body)
    end
  end

  context 'when not logged in as a user' do
    scenario 'it redirects to login page' do
      visit answers_path(@question.id)

      expect(page).to have_content('You need to log in or create an account before continuing.')
    end
  end
end
