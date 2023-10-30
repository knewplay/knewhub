require 'rails_helper'

RSpec.describe Question, type: :model do
  describe '#valid?' do
    subject(:question) { build(:question) }

    it 'returns false when not associated with a Repository' do
      question.repository = nil
      expect(question).not_to be_valid
    end

    it 'returns false when body is nil' do
      question.body = nil
      expect(question).not_to be_valid
    end

    it 'returns false when tag is nil' do
      question.tag = nil
      expect(question).not_to be_valid
    end

    it 'returns false when page_path is nil' do
      question.page_path = nil
      expect(question).not_to be_valid
    end

    it 'returns false when batch_code is nil' do
      question.batch_code = nil
      expect(question).not_to be_valid
    end

    it 'returns true when body, tag, page_path and batch_code are set, and when associated with a Repository' do
      expect(question).to be_valid
    end
  end
end
