class CollectionsController < ApplicationController
  before_action :store_request_in_thread, only: [:show]
  before_action :modify_view_path

  def show
    @file_path = "#{params[:owner]}/#{params[:name]}/#{params[:path]}"
    respond_to do |format|
      format.html { render @file_path }
      format.any(:png, :jpg, :jpeg) do
        send_file "#{Rails.root}/repos/#{@file_path}.#{request.format.to_sym}"
      end
      format.all { render html: 'This file format cannot be rendered' }
    end
  end

  def index
    render "#{params[:owner]}/#{params[:name]}/index"
  end

  private

  def store_request_in_thread
    Thread.current[:request] = request
  end

  def modify_view_path
    prepend_view_path "#{Rails.root}/repos"
  end
end
