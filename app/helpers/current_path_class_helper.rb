module CurrentPathClassHelper
  def current_path_class(path)
    'sidebar__current' if request.path == path
  end
end
