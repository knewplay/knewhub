class RepositoriesController < ApplicationController
  before_action :store_request_in_thread, only: [:show]

  def index; end

  def show
    prepend_view_path "#{Rails.root}/repos"
    @file_path = "#{params[:owner]}/#{params[:name]}/#{params[:path]}"
    respond_to do |format|
      format.md { render @file_path, content_type: 'text/html' }
      format.any(:png, :jpg, :jpeg) do
        send_file "#{Rails.root}/repos/#{@file_path}.#{request.format.to_sym}", type: request.format
      end
      format.all { render html: 'This file format cannot be rendered' }
    end
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
end
