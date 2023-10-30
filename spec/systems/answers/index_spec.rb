require 'rails_helper'

RSpec.describe 'Answers#index', type: :system do
  let!(:first_user) { create(:user, email: 'email1@test.com') }
  let!(:second_user) { create(:user, email: 'email2@test.com') }
  let!(:question) { create(:question) }
  let!(:first_answer) { create(:answer, user: first_user, question:, body: 'This is the first answer.') }
  let!(:second_answer) { create(:answer, user: second_user, question:, body: 'This is the second answer.') }

  context 'when logged in as a user' do
    it 'displays all answers associated with a question' do
      sign_in first_user
      visit answers_path(question.id)

      expect(page).to have_content(question.body)
      expect(page).to have_content(first_answer.body)
      expect(page).to have_content(second_answer.body)
    end
  end

  context 'when not logged in as a user' do
    it 'redirects to login page' do
      visit answers_path(question.id)

      expect(page).to have_content('You need to log in or create an account before continuing.')
    end
  end
end
