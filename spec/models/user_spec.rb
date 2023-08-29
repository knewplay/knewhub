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
end
