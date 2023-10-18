require 'rails_helper'

RSpec.describe 'Likes#destroy', type: :system do
  let!(:answer) { create(:answer) }
  let!(:question) { answer.question }
  let!(:user_author) { answer.user }
  let!(:user_liker) { create(:user, email: 'like_user@email.com') }
  let!(:like) { Like.create(user: user_liker, answer:) }

  context 'when logged in as a user' do
    scenario 'can unlike an answer that has one like' do
      sign_in user_liker
      visit answers_path(question.id)

      expect(page).to have_css('.like--count', text: '1')

      within "#question_#{question.id}_answer_#{answer.id}" do
        click_on 'Remove like'
      end

      expect(page).to_not have_css('.like--count')
    end

    scenario 'can unlike an answer that has multiple likes' do
      Like.create(user: user_author, answer:)

      sign_in user_liker
      visit answers_path(question.id)

      expect(page).to have_css('.like--count', text: '2')

      within "#question_#{question.id}_answer_#{answer.id}" do
        click_on 'Remove like'
      end

      expect(page).to have_css('.like--count', text: '1')
    end
  end

  context 'when not logged in as a user' do
    scenario 'it redirects to login page' do
      visit answers_path(question.id)

      expect(page).to have_content('You need to log in or create an account before continuing.')
    end
  end
end
