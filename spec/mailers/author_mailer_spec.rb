require 'rails_helper'

RSpec.describe AuthorMailer do
  describe 'github_installation_deleted' do
    let!(:github_installation) { create(:github_installation) }
    let!(:repository) { create(:repository, github_installation:) }
    let!(:mail) { described_class.github_installation_deleted(github_installation) }

    it 'renders the headers' do
      expect(mail.subject).to eq('GitHub Installation deleted from KnewHub')
      expect(mail.to).to eq([github_installation.author.user.email])
    end

    it 'renders the body containing information on the github installation' do
      expect(mail.body.encoded).to match("Installation ID: #{github_installation.installation_id}")
      expect(mail.body.encoded).to match("GitHub account: #{github_installation.username}")
    end

    it 'renders the body containing information on the repositories' do
      expect(mail.body.encoded).to match(repository.name)
    end
  end
end
