require 'rails_helper'

RSpec.describe Author, type: :model do
  describe '#set_name' do
    before do
      @author = described_class.new(github_uid: '12345', github_username: 'user')
    end

    it "uses the 'github_username'" do
      @author.save
      expect(@author.name).to eq(@author.github_username)
    end
  end
end
