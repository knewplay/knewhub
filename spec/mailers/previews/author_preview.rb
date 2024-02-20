require 'factory_bot_rails'

# Preview all emails at http://localhost:3000/rails/mailers/author
class AuthorPreview < PreviewMailer
  include FactoryBot::Syntax::Methods

  def github_installation_deleted
    github_installation = create(:github_installation)
    create(:repository, github_installation:)
    AuthorMailer.github_installation_deleted(github_installation)
  end
end
