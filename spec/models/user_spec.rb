require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#valid?' do
    it 'returns false when given an invalid email address' do
      user = build(:user, email: 'invalid_email.com')
      expect(user.valid?).to be false
    end

    it 'returns false when given an invalid password' do
      user = build(:user, password: 'short')
      expect(user.valid?).to be false
    end

    it 'returns true when given a valid email and password' do
      user = build(:user)
      expect(user.valid?).to be true
    end
  end

  describe '#set_reset_password_token' do
    subject { create(:user) }

    it 'returns the plaintext token' do
      potential_token = subject.send(:set_reset_password_token)
      potential_token_digest = Devise.token_generator.digest(subject, :reset_password_token, potential_token)
      actual_token_digest = subject.reset_password_token
      expect(potential_token_digest).to eql(actual_token_digest)
    end
  end
end
