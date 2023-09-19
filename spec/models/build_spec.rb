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

  describe '#no_failures?' do
    let(:build) { create(:build, action: 'update') }

    context 'when logs have failure set to false' do
      before do
        create_list(:log, 2, build:)
      end

      it 'returns true' do
        expect(build.no_failures?).to be(true)
      end
    end

    context 'when one of the logs has failure set to true' do
      before do
        create(:log, build:)
        create(:log, failure: true, build:)
      end

      it 'returns false' do
        expect(build.no_failures?).to be(false)
      end
    end
  end

  describe '#verify_complete' do
    let(:build) { create(:build, action: 'update') }

    context 'when a build has no failed logs and reached the max log count' do
      before do
        create_list(:log, 3, build:)
      end

      it "updates the status to 'Complete'" do
        expect { build.verify_complete }.to change { build.status }.from('In progress').to('Complete')
      end

      it 'fills the completed_at date and time' do
        freeze_time do
          expect { build.verify_complete }.to change { build.completed_at }.from(nil).to(Time.now)
        end
      end

      context 'when a build has no failed logs and has not reached the max log count' do
        before do
          create(:log, build:)
        end

        it 'does not update the status' do
          expect { build.verify_complete }.not_to change { build.status }.from('In progress')
        end

        it 'does not update the completed_at date and time' do
          expect { build.verify_complete }.not_to change { build.completed_at }.from(nil)
        end
      end
    end

    describe '#verify_failed' do
      let(:build) { create(:build, action: 'update') }

      context 'when a build has some failed logs and reached the max log count' do
        before do
          create_list(:log, 2, build:)
          create(:log, failure: true, build:)
        end

        it "updates the status to 'failed'" do
          expect { build.verify_failed }.to change { build.status }.from('In progress').to('Failed')
        end

        it 'fills the completed_at date and time' do
          freeze_time do
            expect { build.verify_failed }.to change { build.completed_at }.from(nil).to(Time.now)
          end
        end
      end

      context 'when a build has no failed logs and has not reached the max log count' do
        before do
          create(:log, build:)
        end

        it 'does not update the status' do
          expect { build.verify_failed }.not_to change { build.status }.from('In progress')
        end

        it 'does not update the completed_at date and time' do
          expect { build.verify_failed }.not_to change { build.completed_at }.from(nil)
        end
      end
    end
  end
end
