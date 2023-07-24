class CollectionsController < ApplicationController
  before_action :store_request_in_thread, only: [:show]
  before_action :modify_view_path

  def show
    file_path = "#{params[:owner]}/#{params[:name]}/#{params[:path]}"
    return head :not_found unless file_exists?(file_path)

    respond_to do |format|
      format.html { render file_path }
      format.any(:png, :jpg, :jpeg) do
        send_file "#{Rails.root}/repos/#{file_path}.#{request.format.to_sym}"
      end
      format.all { head :not_implemented }
    end
  end

  def index
    file_path = "#{params[:owner]}/#{params[:name]}/index"
    return head :not_found unless file_exists?(file_path)

    render file_path
  end

  private

  def store_request_in_thread
    Thread.current[:request] = request
  end

  def modify_view_path
    prepend_view_path "#{Rails.root}/repos"
  end

  def file_exists?(file_path)
    File.exist?("#{Rails.root}/repos/#{file_path}.md") \
    || File.exist?("#{Rails.root}/repos/#{file_path}.#{request.format.to_sym}")
  end
end
