require 'rails_helper'

RSpec.describe Build, type: :model do
  describe '#valid?' do
    subject { described_class.new }

    it 'returns false when not associated with a Repository' do
      subject.status = 'Created'
      expect(subject).to_not be_valid
    end

    it 'returns false when status is nil' do
      subject.repository = create(:repository)
      expect(subject).to_not be_valid
    end

    it 'returns true when status is set and when associated with a Repository' do
      subject.repository = create(:repository)
      subject.status = 'Created'
      expect(subject).to be_valid
    end
  end
end
