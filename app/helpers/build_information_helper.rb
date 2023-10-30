module BuildInformationHelper
  def build_information(build)
    return if build.nil?

    "'#{build.action}' | #{local_time(build.completed_at)}"
  end

  def build_status_icon(build)
    return if build.nil?

    options = { 'aria-hidden': 'true', title: build.status }
    case build.status
    when 'Complete'
      options[:class] = 'fa-regular fa-circle-check'
      options[:style] = 'color: #4ea832;'
    when 'Failed'
      options[:class] = 'fa-regular fa-circle-xmark'
      options[:style] = 'color: #c23434;'
    when 'In progress'
      options[:class] = 'fa-solid fa-spinner fa-spin'
    end
    content_tag(:i, '', options)
  end
end
