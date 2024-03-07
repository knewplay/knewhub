require 'rails_helper'

describe AutodeskFileUpload do
  before(:all) do
    @repo = create(:repository)
  end

  context 'when valid client credentials are provided' do
    before(:all) do
      @build_valid = create(:build, repository: @repo, aasm_state: :uploading_autodesk_files)
      VCR.use_cassette('get_autodesk_access_token') do
        @autodesk_service = described_class.new(@build_valid)
      end
      directory = 'repos/author/repo_owner/repo_name/chapter-2/3d-files'
      FileUtils.mkdir_p directory
      source_filepath = Rails.root.join('spec/fixtures/systems/collections/chapter-2/3d-files/nist-ctc-01-asme1-rd.stp')
      @filepath = "#{directory}/nist-ctc-01-asme1-rd.stp"
      FileUtils.copy_file(source_filepath, @filepath)
    end

    after(:all) do
      FileUtils.rm_r('repos/author')
    end

    describe '#initialize' do
      it 'adds a log to the build' do
        expect(@build_valid.logs.first.content).to eq('Autodesk access token successfully created.')
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
          expect(@build_valid.logs.last.content).to eq("'#{@filepath}' successfully uploaded to Autodesk servers.")
        end
      end
    end
  end

  context 'when invalid client credentials are provided' do
    before(:all) do
      VCR.use_cassette('get_autodesk_access_token_invalid') do
        @build_invalid = create(:build, repository: @repo, aasm_state: :uploading_autodesk_files)
        @autodesk_service = described_class.new(@build_invalid)
      end
    end

    describe '#initialize' do
      it 'adds a log to the build' do
        expect(@build_invalid.logs.first.content).to match('Failed to create Autodesk access token.')
      end
    end

    describe '#upload_file_for_viewer' do
      it 'adds a log to the build' do
        @autodesk_service.upload_file_for_viewer('somefile.stp')
        expect(@build_invalid.logs.second.content).to match(
          'Unable to upload file to Autodesk server due to invalid access token.'
        )
      end
    end
  end
end
