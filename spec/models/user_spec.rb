require 'rails_helper'

RSpec.describe User do
  describe '#valid?' do
    subject(:user) { build(:user) }

    it 'returns false when given an invalid email address' do
      user.email = 'invalid_email.com'
      expect(user.valid?).to be false
    end

    it 'returns false when given an invalid password' do
      user.password = 'short'
      expect(user.valid?).to be false
    end

    it 'returns true when given a valid email and password' do
      expect(user.valid?).to be true
    end
  end

  # Devise method
  describe '#set_reset_password_token' do
    subject(:user) { create(:user) }

    it 'returns the plaintext token' do
      potential_token = user.send(:set_reset_password_token)
      potential_token_digest = Devise.token_generator.digest(user, :reset_password_token, potential_token)
      actual_token_digest = user.reset_password_token
      expect(potential_token_digest).to eql(actual_token_digest)
    end
  end
end
