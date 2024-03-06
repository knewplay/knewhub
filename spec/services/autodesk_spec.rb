require 'rails_helper'

describe Autodesk do
  let!(:autodesk) do
    VCR.use_cassette('get_autodesk_access_token') do
      described_class.new
    end
  end

  before(:all) do
    directory = 'repos/author/repo_owner/repo_name/chapter-2/3d-files'
    FileUtils.mkdir_p directory
    source_filepath = Rails.root.join('spec/fixtures/systems/collections/chapter-2/3d-files/nist_ctc_01_asme1_rd.stp')
    @filepath = "#{directory}/nist_ctc_01_asme1_rd.stp"
    FileUtils.copy_file(source_filepath, @filepath)
  end

  after(:all) do
    FileUtils.rm_r('repos/author')
  end

  describe '#upload_file_for_viewer' do
    it 'completes the upload process' do
      allow(Rails.logger).to receive(:info)
      VCR.use_cassette('upload_3d_file_autodesk') do
        @value = autodesk.upload_file_for_viewer(@filepath)
      end
      expect(Rails.logger).to have_received(:info).with("Starting upload of file '#{@filepath}' to Autodesk bucket")
      expect(Rails.logger).to have_received(:info).with("Finalizing upload of file '#{@filepath}' to Autodesk bucket")
      expect(Rails.logger).to have_received(:info).with('Success. File will be added to viewer')
      expect(@value).not_to be_nil
      expect(@value).to be_a String
    end
  end
end
