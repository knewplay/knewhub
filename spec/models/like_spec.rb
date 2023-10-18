require 'rails_helper'

RSpec.describe Like, type: :model do
  describe '#valid?' do
    let(:answer) { create(:answer) }
    let(:user_author) { answer.user }
    let(:user_liker) { create(:user, email: 'like_user@email.com') }
    subject { Like.new(answer:) }

    context 'when a user likes an anwer' do
      it 'returns true when someone else wrote the answer' do
        subject.user = user_liker
        expect(subject).to be_valid
      end

      it 'returns true when their wrote the answer' do
        subject.user = user_author
        expect(subject).to be_valid
      end

      it 'returns false when they already liked the answer' do
        Like.create(answer:, user: user_liker)
        subject.user = user_liker
        expect(subject).to_not be_valid
      end
    end
  end
end
