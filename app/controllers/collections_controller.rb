class CollectionsController < ApplicationController
  before_action :modify_view_path
  layout 'collections_page'

  def show
    file_path = "#{params[:owner]}/#{params[:name]}/#{params[:path]}"
    render_not_found and return unless valid_render?(file_path, params[:owner], params[:name])

    RequestPath.store(request)
    respond_to do |format|
      format.html do
        @front_matter = extract_front_matter(file_path)
        render file_path
      end
      format.any(:png, :jpg, :jpeg, :gif, :svg, :webp) do
        send_file "#{Rails.root}/repos/#{file_path}.#{request.format.to_sym}"
      end
      format.all { render_not_found }
    end
  end

  def index
    file_path = "#{params[:owner]}/#{params[:name]}/index"
    render_not_found and return unless valid_render?(file_path, params[:owner], params[:name])

    @front_matter = extract_front_matter(file_path)
    render file_path
  end

  private

  def modify_view_path
    prepend_view_path "#{Rails.root}/repos"
  end

  def file_exists?(file_path)
    File.exist?("#{Rails.root}/repos/#{file_path}.md") \
    || File.exist?("#{Rails.root}/repos/#{file_path}.#{request.format.to_sym}")
  end

  def repository_visible?(owner, name)
    author_id = Author.find_by(github_username: owner).id
    repository = Repository.find_by(author_id:, name:)

    repository.banned == false
  end

  def valid_render?(file_path, owner, name)
    return true if file_exists?(file_path) && repository_visible?(owner, name)

    false
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  def extract_front_matter(file_path)
    file = "#{Rails.root}/repos/#{file_path}.md"
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date])
    FrontMatterParser::Parser.parse_file(file, loader:).front_matter
  end
end
