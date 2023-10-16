require 'rails_helper'

RSpec.describe Administrator, type: :model do
  describe '#normalizes' do
    it 'does not change the name if not required' do
      admin = create(:administrator, name: 'valid-name')
      expect(admin.name).to eq('valid-name')
    end

    it 'changes the name when required' do
      admin = create(:administrator, name: '  name-with-spaces-around ')
      expect(admin.name).to eq('name-with-spaces-around')
    end
  end

  describe '#valid?' do
    subject { build(:administrator) }

    it 'returns false when name contains invalid characters' do
      subject.name = 'invalid!name%'
      expect(subject).to_not be_valid
    end

    it 'returns false when permissions is nil' do
      subject.permissions = nil
      expect(subject).to_not be_valid
    end

    it 'returns false when password is too short' do
      subject.password = '123'
      expect(subject).to_not be_valid
    end

    it 'returns true when name and password have valid formats, and when permissions are set' do
      expect(subject).to be_valid
    end
  end
end
