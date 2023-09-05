require 'rails_helper'

RSpec.describe Log, type: :model do
  describe '#valid?' do
    subject { described_class.new }

    it 'returns false when not associated with a Build' do
      subject.content = 'Some log content.'
      expect(subject).to_not be_valid
    end

    it 'returns false when content is nil' do
      subject.build = create(:build)
      expect(subject).to_not be_valid
    end

    it 'returns true when content is set and when associated with a Build' do
      subject.build = create(:build)
      subject.content = 'Some log content.'
      expect(subject).to be_valid
    end
  end
end
