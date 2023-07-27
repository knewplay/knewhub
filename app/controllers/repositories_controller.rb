class RepositoriesController < ApplicationController
  before_action :require_author_authentication, only: %i[new create]

  def index; end

  def new
    @repository = current_author.repositories.build
  end

  def create
    @repository = current_author.repositories.build(repository_params)
    if @repository.save
      CreateGithubWebhookJob.perform_async(
        @repository.uuid,
        @repository.name,
        @repository.author.github_username,
        @repository.token
      )
      redirect_to repositories_path, notice: 'Repository was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def repository_params
    params.require(:repository).permit(:name, :token, :branch)
  end
end
