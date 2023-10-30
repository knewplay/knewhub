require 'rails_helper'

RSpec.describe Build, type: :model do
  describe '#valid?' do
    subject(:build_instance) { build(:build) }

    it 'returns false when not associated with a Repository' do
      build_instance.repository = nil
      expect(build_instance).not_to be_valid
    end

    it 'returns false when status is nil' do
      build_instance.status = nil
      expect(build_instance).not_to be_valid
    end

    it 'returns false when action is nil' do
      build_instance.action = nil
      expect(build_instance).not_to be_valid
    end

    it 'returns true when status is set and when associated with a Repository' do
      expect(build_instance).to be_valid
    end
  end
end
