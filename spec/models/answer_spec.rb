require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe '#valid?' do
    let(:user) { create(:user, :second) }
    let(:question) { create(:question) }
    subject { build(:answer, user:, question:) }

    context 'when a user has an answer associated with a question' do
      it 'returns true when body is valid' do
        expect(subject).to be_valid
      end

      it 'returns false when body is nil' do
        subject.body = nil
        expect(subject).to_not be_valid
      end
    end

    context 'when a user has multiple answers associated with a question' do
      let(:second_answer) { build(:answer, user:, question:) }

      it 'returns true for the first answer' do
        expect(subject).to be_valid
      end

      it 'returns false for the second answer' do
        expect(second_answer).to_not be_nil
      end
    end

    context 'when no user is associated with an answer to a question' do
      it 'returns false' do
        subject.user = nil
        expect(subject).to_not be_valid
      end
    end

    context 'when an answer is not associated to a question' do
      it 'returns false' do
        subject.question = nil
        expect(subject).to_not be_valid
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
