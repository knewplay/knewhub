class CollectionsController < ApplicationController
  before_action :require_user_or_admin_authentication, :modify_view_path
  layout 'collections'

  def index
    file_path = "#{params[:owner]}/#{params[:name]}/index"
    render_not_found and return unless valid_render?(file_path, params[:owner], params[:name])

    extract_markdown_file(file_path)
    render file_path
  end

  def show
    file_path = "#{params[:owner]}/#{params[:name]}/#{params[:path]}"
    render_not_found and return unless valid_render?(file_path, params[:owner], params[:name])

    RequestPath.store(request)
    show_actions(file_path)
  end

  private

  def require_user_or_admin_authentication
    return if administrator_signed_in? || user_signed_in?

    redirect_to root_path, alert: 'Please log in to continue.'
  end

  def modify_view_path
    prepend_view_path Rails.root.join('repos').to_s
  end

  def show_actions(file_path)
    respond_to do |format|
      format.html do
        extract_markdown_file(file_path)
        @questions = Question.where(repository: @repository, page_path: params[:path])
        render file_path
      end
      format.any(:png, :jpg, :jpeg, :gif, :svg, :webp) { render_image(file_path) }
      format.all { render_not_found }
    end
  end

  def file_exists?(file_path)
    File.exist?(Rails.root.join("repos/#{file_path}.md").to_s) \
    || File.exist?(Rails.root.join("repos/#{file_path}.#{request.format.to_sym}").to_s)
  end

  def repository_visible?(owner, name)
    author_id = Author.find_by(github_username: owner).id
    @repository = Repository.find_by(author_id:, name:)

    @repository.visible?
  end

  def valid_render?(file_path, owner, name)
    return true if file_exists?(file_path) && repository_visible?(owner, name)

    false
  end

  def render_not_found
    render 'errors/not_found', layout: 'errors', status: :not_found
  end

  def render_image(file_path)
    send_file Rails.root.join("repos/#{file_path}.#{request.format.to_sym}").to_s
  end

  def extract_markdown_file(file_path)
    absolute_path = Rails.root.join("repos/#{file_path}.md").to_s
    @front_matter, @markdown_content = helpers.split_markdown(absolute_path)
  end
end
