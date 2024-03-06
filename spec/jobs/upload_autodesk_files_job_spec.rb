require 'rails_helper'

RSpec.describe UploadAutodeskFilesJob do
  before(:all) do
    @repo = create(:repository)
    @build = create(:build, repository: @repo, aasm_state: :uploading_autodesk_files)
    destination_directory = @repo.storage_path
    source_directory = Rails.root.join('spec/fixtures/systems/collections')
    FileUtils.mkdir_p(destination_directory)
    FileUtils.copy_entry(source_directory, destination_directory)
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author_username)
    FileUtils.remove_dir(parent_directory)
  end

  it 'queues the job' do
    described_class.perform_async(@build.id)
    expect(described_class).to have_enqueued_sidekiq_job(@build.id)
  end

  context 'when executing perform' do
    before(:all) do
      Sidekiq::Testing.inline! do
        VCR.use_cassettes(
          [{ name: 'get_autodesk_access_token', options: { allow_playback_repeats: true } },
           { name: 'upload_3d_file_autodesk_additional' },
           { name: 'upload_3d_file_autodesk' }]
        ) do
          described_class.perform_async(@build.id)
        end
      end
      @repo.reload
      @autodesk_file_one = @repo.autodesk_files.first
      @autodesk_file_two = @repo.autodesk_files.last
    end

    it 'creates two autodesk files associated with the repository' do
      expect(@repo.autodesk_files.count).to eq(2)
    end

    it 'the associated autodesk files contain the filepath' do
      expect(@autodesk_file_one.filepath).to eq(
        'repos/author/repo_owner/repo_name/chapter-1/3d-files/nist_ctc_02_asme1_rc.stp'
      )
      expect(@autodesk_file_two.filepath).to eq(
        'repos/author/repo_owner/repo_name/chapter-2/3d-files/nist_ctc_01_asme1_rd.stp'
      )
    end

    it 'the associated autodesk files contain contains the urn' do
      expect(@autodesk_file_one.urn).to eq(
        'dXJuOmFkc2sub2JqZWN0czpvcy5vYmplY3Q6a25ld2h1Yl8zZF9maWxlcy9yZXBvcyUyRmF1dGhvciUyRnJl' \
        'cG9fb3duZXIlMkZyZXBvX25hbWUlMkYzZC1maWxlJTJGbmlzdF9jdGNfMDJfYXNtZTFfcmMuc3Rw'
      )
      expect(@autodesk_file_two.urn).to eq(
        'dXJuOmFkc2sub2JqZWN0czpvcy5vYmplY3Q6a25ld2h1Yl8zZF9maWxlcy9yZXBvcyUyRmF1dGhvciUyRnJl' \
        'cG9fb3duZXIlMkZyZXBvX25hbWUlMkYzZC1maWxlJTJGbmlzdF9jdGNfMDFfYXNtZTFfcmQuc3Rw'
      )
    end
  end
end
