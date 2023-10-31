module BuildInformationHelper
  def build_information(build)
    return if build.nil?

    "'#{build.action}' | #{local_time(build.completed_at)}"
  end

  def build_status_icon(build)
    return if build.nil?

    status_icon = {
      'Complete': { class: 'fa-regular fa-circle-check', style: 'color: #4ea832;' },
      'Failed': { class: 'fa-regular fa-circle-xmark', style: 'color: #c23434;' },
      'In progress': { class: 'fa-solid fa-spinner fa-spin' }
    }

    options = { 'aria-hidden': 'true', title: build.status }
    options.merge!(status_icon[build.status.to_sym])
    content_tag(:i, '', options)
  end
end
