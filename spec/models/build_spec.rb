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

  describe '#current_step' do
    context 'when duplicates of a log exists' do
      before do
        create(:log, step: 1)
        build = Log.last.build
        create_list(:log, 2, step: 2, build:)
      end

      it 'only counts the log once' do
        expect(Build.last.current_step).to eq(2)
      end
    end

    context 'when logs are out of order' do
      before do
        create(:log, step: 3)
        build = Log.last.build
        create(:log, step: 1, build:)
      end

      it 'returns the correct step regardless' do
        expect(Build.last.current_step).to eq(2)
      end
    end
  end
end
