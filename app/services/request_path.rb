# Define the absolute path of files requested by CustomRender through CollectionsController
# This is to allow Markdown files to find other files that are within the same repository (code files, Autodesk files)
class RequestPath
  def self.store(request)
    Thread.current[:request] = request
  end

  def self.define_base_url
    request_path = Thread.current[:request].fullpath
    # request_path = "/collections/jp524/jp524/markdown-templates/pages/chapter-2/chapter-2-article-1"

    match_data = request_path.match(%r{(.+/)(.+)})
    folder_path = match_data[1]
    # folder_path = "/collections/jp524/jp524/markdown-templates/pages/chapter-2/"

    folder_path.gsub(%r{(/collections/)}, '/repos/').gsub(%r{(/pages/)}, '/')
    # Location of corresponding folder on server: "/repos/jp524/jp524/markdown-templates/chapter-2/""
  end
end
