require 'rails_helper'

describe Autodesk do
  let!(:autodesk) { described_class.new }

  describe '#access_token' do
    it 'returns the access token for the current client' do
      VCR.use_cassette('get_autodesk_access_token') do
        @access_token = autodesk.access_token
      end
      expect(@access_token).not_to be_nil
      expect(@access_token).to be_a String
    end
  end
end
