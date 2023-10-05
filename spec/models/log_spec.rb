require 'rails_helper'

RSpec.describe Log, type: :model do
  describe '#valid?' do
    subject { build(:log) }

    it 'returns false when not associated with a Build' do
      subject.build = nil
      expect(subject).to_not be_valid
    end

    it 'returns false when content is nil' do
      subject.content = nil
      expect(subject).to_not be_valid
    end

    it 'returns true when content and step are set and when associated with a Build' do
      expect(subject).to be_valid
    end
  end
end
