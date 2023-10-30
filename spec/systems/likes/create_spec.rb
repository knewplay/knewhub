require 'rails_helper'

RSpec.describe 'Likes#create', type: :system do
  let!(:answer) { create(:answer) }
  let!(:question) { answer.question }
  let!(:user_author) { answer.user }
  let!(:user_liker) { create(:user, email: 'like_user@email.com') }

  context 'when logged in as a user' do
    it 'can like an answer with no likes' do
      sign_in user_liker
      visit answers_path(question.id)

      within "#question_#{question.id}_answer_#{answer.id}" do
        click_on 'Like answer'
      end

      expect(page).to have_css('.like--count', text: '1')
    end

    it 'can like an answer already having likes' do
      Like.create(user: user_author, answer:)

      sign_in user_liker
      visit answers_path(question.id)

      within "#question_#{question.id}_answer_#{answer.id}" do
        click_on 'Like answer'
      end

      expect(page).to have_css('.like--count', text: '2')
    end
  end

  context 'when not logged in as a user' do
    it 'redirects to login page' do
      visit answers_path(question.id)

      expect(page).to have_content('You need to log in or create an account before continuing.')
    end
  end
end
