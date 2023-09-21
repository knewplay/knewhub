class CollectionsController < ApplicationController
  layout 'collections'

  def show
    file_path = "#{params[:owner]}/#{params[:name]}/#{params[:path]}"
    render_not_found and return unless valid_render?(file_path, params[:owner], params[:name])

    RequestPath.store(request)
    respond_to do |format|
      format.html do
        @front_matter = extract_front_matter(file_path)
        prepend_view_path "#{Rails.root}/repos"
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
    prepend_view_path "#{Rails.root}/repos"
    render file_path
  end

  private

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
    render 'errors/not_found', layout: 'application', status: :not_found
  end

  def extract_front_matter(file_path)
    file = "#{Rails.root}/repos/#{file_path}.md"
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date])
    FrontMatterParser::Parser.parse_file(file, loader:).front_matter
  end
end
