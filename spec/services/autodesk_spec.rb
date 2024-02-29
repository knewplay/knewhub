require 'rails_helper'

describe Autodesk do
  let!(:autodesk) do
    VCR.use_cassette('get_autodesk_access_token') do
      described_class.new
    end
  end

  before do
    directory = 'repos/author/repo_owner/repo_name/3d-file'
    FileUtils.mkdir_p directory
    @filepath = "#{directory}/test.step"
    FileUtils.touch(@filepath)
  end

  after do
    FileUtils.rm_r('repos/author')
  end

  describe '#create_storage_bucket' do
    it 'returns the URN of the uploaded file encoded in Base64' do
      VCR.use_cassette('upload_3d_file_autodesk') do
        @value = autodesk.upload_file(@filepath)
      end
      expect(@value).not_to be_nil
      expect(@value).to be_a String
    end
  end
end
