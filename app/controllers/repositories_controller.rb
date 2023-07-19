class RepositoriesController < ApplicationController
  before_action :store_request_in_thread, only: [:show]
  before_action :modify_view_path, only: %i[show main]

  def index; end

  def show
    @file_path = "#{params[:owner]}/#{params[:name]}/#{params[:path]}"
    respond_to do |format|
      format.html { render @file_path }
      # Redirect is required for .md format in order to use application layout
      format.md { redirect_to request.fullpath.delete_suffix('.md') }
      format.any(:png, :jpg, :jpeg) do
        send_file "#{Rails.root}/repos/#{@file_path}.#{request.format.to_sym}", type: request.format
      end
      format.all { render html: 'This file format cannot be rendered' }
    end
  end

  def main
    render "#{params[:owner]}/#{params[:name]}/index"
  end

  def new
    @repository = Repository.new
  end

  def create
    @repository = Repository.new(repository_params)
    if @repository.save
      CreateGithubWebhookJob.perform_async(owner, name, token)
      redirect_to repositories_path, notice: 'Repository was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def repository_params
    params.require(:repository).permit(:owner, :name, :token, :branch)
  end

  def store_request_in_thread
    Thread.current[:request] = request
  end

  def modify_view_path
    prepend_view_path "#{Rails.root}/repos"
  end
end
