require 'rails_helper'

describe Autodesk do
  describe '#initialize' do
    context 'when valid client credentials are provided' do
      let!(:autodesk) do
        VCR.use_cassette('get_autodesk_access_token') do
          described_class.new
        end
      end

      it 'creates an access token' do
        expect(autodesk.access_token).not_to be_nil
        expect(autodesk.access_token).to be_a String
      end

      it "doesn't have an access token error message" do
        expect(autodesk.access_token_error_msg).to be_nil
      end
    end

    context 'when invalid client credentials are provided' do
      let!(:autodesk) do
        VCR.use_cassette('get_autodesk_access_token_invalid') do
          described_class.new
        end
      end

      it "doesn't have an access token" do
        expect(autodesk.access_token).to be_nil
      end

      it 'has an access token error message' do
        expect(autodesk.access_token_error_msg).not_to be_nil
      end
    end
  end
end
