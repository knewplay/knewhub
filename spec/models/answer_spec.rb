require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe '#valid?' do
    subject(:answer) { build(:answer, user:, question:) }

    let(:user) { create(:user, :second) }
    let(:question) { create(:question) }

    context 'when a user has an answer associated with a question' do
      it 'returns true when body is valid' do
        expect(answer).to be_valid
      end

      it 'returns false when body is nil' do
        answer.body = nil
        expect(answer).not_to be_valid
      end
    end

    context 'when a user has multiple answers associated with a question' do
      let(:second_answer) { build(:answer, user:, question:) }

      it 'returns true for the first answer' do
        expect(answer).to be_valid
      end

      it 'returns false for the second answer' do
        expect(second_answer).not_to be_nil
      end
    end

    context 'when no user is associated with an answer to a question' do
      it 'returns false' do
        answer.user = nil
        expect(answer).not_to be_valid
      end
    end

    context 'when an answer is not associated to a question' do
      it 'returns false' do
        answer.question = nil
        expect(answer).not_to be_valid
      end
    end
  end

  describe '#liked_by_user' do
    let!(:answer) { create(:answer) }
    let!(:user_author) { answer.user }
    let!(:user_liker) { create(:user, email: 'like_user@email.com') }
    let!(:like) { Like.create(answer:, user: user_liker) }

    context 'when the user liked the answer' do
      it 'returns the Like record' do
        expect(answer.liked_by_user(user_liker)).to eq(like)
      end
    end

    context 'when the user did not like the answer' do
      it 'returns nil' do
        expect(answer.liked_by_user(user_author)).to be_nil
      end
    end
  end
end
