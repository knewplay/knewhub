require 'rails_helper'

RSpec.describe Author do
  describe '#set_name' do
    let(:author) { create(:author, github_username: 'user') }

    it "uses the 'github_username'" do
      expect(author.name).to eq(author.github_username)
    end
  end
end
