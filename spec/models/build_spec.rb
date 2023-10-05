require 'rails_helper'

RSpec.describe Build, type: :model do
  describe '#valid?' do
    subject { build(:build) }

    it 'returns false when not associated with a Repository' do
      subject.repository = nil
      expect(subject).to_not be_valid
    end

    it 'returns false when status is nil' do
      subject.status = nil
      expect(subject).to_not be_valid
    end

    it 'returns false when action is nil' do
      subject.action = nil
      expect(subject).to_not be_valid
    end

    it 'returns true when status is set and when associated with a Repository' do
      expect(subject).to be_valid
    end
  end
end
