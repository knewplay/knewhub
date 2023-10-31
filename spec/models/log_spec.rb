require 'rails_helper'

RSpec.describe Log do
  describe '#valid?' do
    subject(:log) { build(:log) }

    it 'returns false when not associated with a Build' do
      log.build = nil
      expect(log).not_to be_valid
    end

    it 'returns false when content is nil' do
      log.content = nil
      expect(log).not_to be_valid
    end

    it 'returns true when content and step are set and when associated with a Build' do
      expect(log).to be_valid
    end
  end
end
