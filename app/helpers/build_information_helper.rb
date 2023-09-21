module BuildInformationHelper
  def build_information(build)
    return if build.nil?

    "'#{build.action}' | #{build.completed_at}"
  end

  def log_tally(build)
    return if build.nil?

    "#{build.logs.count}/#{build.max_log_count}"
  end

  def build_status_icon(build)
    return if build.nil?

    attributes = "aria-hidden='true' title='#{build.status}"

    case build.status
    when 'Complete'
      "<i class='fa-regular fa-circle-check' style='color: #4ea832;' #{attributes}'></i>".html_safe
    when 'Failed'
      "<i class='fa-regular fa-circle-xmark' style='color: #c23434;' #{attributes}'></i>".html_safe
    when 'In progress'
      "<i class='fa-solid fa-spinner fa-spin' #{attributes}'></i>".html_safe
    end
  end
end
