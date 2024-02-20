class AuthorMailer < ApplicationMailer
  def github_installation_deleted(github_installation)
    @github_installation = github_installation
    @author = github_installation.author

    mail to: @author.user.email, subject: 'GitHub Installation deleted from KnewHub'
  end
end
