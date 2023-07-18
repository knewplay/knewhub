class RepositoriesController < ApplicationController
  def index; end

  def new
    @repository = Repository.new
  end

  def create
    @repository = Repository.new(repository_params)
    if @repository.save
      CreateGithubWebhookJob.perform_later(@repository)
      redirect_to repositories_path, notice: 'Repository was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def repository_params
    params.require(:repository).permit(:owner, :name, :token, :branch)
  end
end
