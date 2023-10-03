require 'rails_helper'

RSpec.describe Question, type: :model do
  describe '#valid?' do
    subject { build(:question) }

    it 'returns false when not associated with a Repository' do
      subject.repository = nil
      expect(subject).to_not be_valid
    end

    it 'returns false when body is nil' do
      subject.body = nil
      expect(subject).to_not be_valid
    end

    it 'returns false when tag is nil' do
      subject.tag = nil
      expect(subject).to_not be_valid
    end

    it 'returns false when page_path is nil' do
      subject.page_path = nil
      expect(subject).to_not be_valid
    end

    it 'returns true when body, tag and page_path are set and when associated with a Repository' do
      expect(subject).to be_valid
    end
  end
end
