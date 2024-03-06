require 'rails_helper'

describe Autodesk do
  let!(:autodesk) do
    VCR.use_cassette('get_autodesk_access_token') do
      described_class.new
    end
  end

  describe '#initialize' do
    it 'creates an access token' do
      expect(autodesk.access_token).not_to be_nil
      expect(autodesk.access_token).to be_a String
    end
  end
end
