module CurrentPathClassHelper
  # Allows the links for the current page to have a class of "sidebar_current"
  def current_path_class(path)
    'sidebar__current' if request.path == path
  end
end
