# Define the absolute path of files requested by CustomRender through CollectionsController
class RequestPath
  def self.store(request)
    Thread.current[:request] = request
  end

  def self.define_base_url
    request_path = Thread.current[:request].fullpath
    match_data = request_path.match(%r{(.+/)(.+)})
    folder_path = match_data[1]
    # Route GET /collections/:owner/:name/pages/*path uses CollectionsController#show action
    # The request route is modified to find where the corresponding file is stored
    folder_path.gsub(%r{(/collections/)}, '/repos/').gsub(%r{(/pages/)}, '/')
  end
end
