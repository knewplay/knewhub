require 'rails_helper'

RSpec.describe RemoveDirectoryJob do
  let!(:repo) { create(:repository, :real) }

  it 'queues the job' do
    described_class.perform_async(repo.storage_path.to_s)
    expect(described_class).to have_enqueued_sidekiq_job(repo.storage_path.to_s)
  end

  context 'when executing perform' do
    before do
      Sidekiq::Testing.inline! do
        described_class.perform_async(repo.storage_path.to_s)
      end
    end

    it 'removes the local directory' do
      expect(Dir.exist?(repo.storage_path)).to be(false)
    end

    it 'does not removes the record from the database' do
      expect(Repository.exists?(repo.id)).to be true
    end
  end
end
