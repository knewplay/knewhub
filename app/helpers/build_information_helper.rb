module BuildInformationHelper
  def build_information(build)
    return if build.nil?

    "'#{build.action}' | #{build.completed_at}"
  end

  def log_tally(build)
    return if build.nil?

    "#{build.logs.count}/#{build.max_log_count}"
  end

  def build_status_icon(build, options = {})
    return if build.nil?

    options[:title] = build.status
    options[:'aria-hidden'] = true
    options[:class] = 'icon'
    path = "icons/builds/#{build.status.parameterize(separator: '_')}.png"

    image_tag(asset_path(path), options)
  end
end
