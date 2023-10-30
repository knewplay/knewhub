require 'rails_helper'

RSpec.describe Like, type: :model do
  describe '#valid?' do
    subject(:like) { described_class.new(answer:) }

    let(:answer) { create(:answer) }
    let(:user_author) { answer.user }
    let(:user_liker) { create(:user, email: 'like_user@email.com') }

    context 'when a user likes an anwer' do
      it 'returns true when someone else wrote the answer' do
        like.user = user_liker
        expect(like).to be_valid
      end

      it 'returns true when their wrote the answer' do
        like.user = user_author
        expect(like).to be_valid
      end

      it 'returns false when they already liked the answer' do
        described_class.create(answer:, user: user_liker)
        like.user = user_liker
        expect(like).not_to be_valid
      end
    end
  end
end
