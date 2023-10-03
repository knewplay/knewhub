module IndexPathHelper
  def index_path(page_path)
    repository_path = page_path.match(/(.+pages)/)[1]
    "#{repository_path}/index"
  end
end
