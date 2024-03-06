require 'rails_helper'

describe Autodesk do
  before(:all) do
    @build = create(:build, aasm_state: :uploading_autodesk_files)
    VCR.use_cassette('get_autodesk_access_token') do
      @autodesk_service = described_class.new(@build)
    end
    directory = 'repos/author/repo_owner/repo_name/chapter-2/3d-files'
    FileUtils.mkdir_p directory
    source_filepath = Rails.root.join('spec/fixtures/systems/collections/chapter-2/3d-files/nist_ctc_01_asme1_rd.stp')
    @filepath = "#{directory}/nist_ctc_01_asme1_rd.stp"
    FileUtils.copy_file(source_filepath, @filepath)
  end

  after(:all) do
    FileUtils.rm_r('repos/author')
  end

  describe '#initialize' do
    it 'adds a log to the build' do
      expect(@build.logs.first.content).to eq('Autodesk access token successfully created.')
    end
  end

  describe '#upload_file_for_viewer' do
    context 'when upload is successful' do
      before(:all) do
        VCR.use_cassette('upload_3d_file_autodesk') do
          @value = @autodesk_service.upload_file_for_viewer(@filepath)
        end
      end

      it 'returns the urn value' do
        expect(@value).not_to be_nil
        expect(@value).to be_a String
      end

      it 'adds a log to the build' do
        expect(@build.logs.last.content).to eq("'#{@filepath}' successfully uploaded to Autodesk servers.")
      end
    end
  end
end
