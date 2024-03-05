require 'rails_helper'

RSpec.describe UploadAutodeskFileJob do
  before(:all) do
    @repo = create(:repository)
    directory = 'repos/author/repo_owner/repo_name/3d-file'
    FileUtils.mkdir_p directory
    source_filepath = Rails.root.join(
      'spec/fixtures/systems/collections/chapter-2/3d-files/V5 Robot Radio (276-4831).step'
    )
    @filepath = "#{directory}/V5 Robot Radio (276-4831).step"
    FileUtils.copy_file(source_filepath, @filepath)
  end

  after(:all) do
    FileUtils.rm_r('repos/author')
  end

  it 'queues the job' do
    described_class.perform_async(
      @repo.id,
      @filepath
    )
    expect(described_class).to have_enqueued_sidekiq_job(
      @repo.id,
      @filepath
    )
  end

  context 'when executing perform' do
    before(:all) do
      Sidekiq::Testing.inline! do
        VCR.use_cassettes([{ name: 'get_autodesk_access_token' }, { name: 'upload_3d_file_autodesk' }]) do
          described_class.perform_async(
            @repo.id,
            @filepath
          )
        end
      end
      @autodesk_file = AutodeskFile.last
    end

    it 'creates an autodesk_file associated with the repository' do
      expect(@autodesk_file.repository).to eq(@repo)
    end

    it 'creates an autodesk_file containing the filepath' do
      expect(@autodesk_file.filepath).to eq(@filepath)
    end

    it 'creates an autodesk_file containing the urn' do
      expect(@autodesk_file.urn).to eq(
        'dXJuOmFkc2sub2JqZWN0czpvcy5vYmplY3Q6a25ld2h1Yl8zZF9maWxlcy9yZXBvcyUyRmF1dGhvciUyRnJl' \
        'cG9fb3duZXIlMkZyZXBvX25hbWUlMkYzZC1maWxlJTJGVjUrUm9ib3QrUmFkaW8rKDI3Ni00ODMxKS5zdGVw'
      )
    end
  end
end
