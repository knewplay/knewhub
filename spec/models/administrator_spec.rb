require 'rails_helper'

RSpec.describe Administrator do
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
    subject(:administrator) { build(:administrator) }

    it 'returns false when name contains invalid characters' do
      administrator.name = 'invalid!name%'
      expect(administrator).not_to be_valid
    end

    it 'returns false when permissions is nil' do
      administrator.permissions = nil
      expect(administrator).not_to be_valid
    end

    it 'returns false when password is too short' do
      administrator.password = '123'
      expect(administrator).not_to be_valid
    end

    it 'returns true when name and password have valid formats, and when permissions are set' do
      expect(administrator).to be_valid
    end
  end
end
