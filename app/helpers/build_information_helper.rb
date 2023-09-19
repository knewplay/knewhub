module BuildInformationHelper
  def build_information(build)
    return if build.nil?

    "'#{build.action}' | #{build.status} | #{build.completed_at}"
  end

  def log_tally(build)
    return if build.nil?

    "#{build.logs.count}/#{build.max_log_count}"
  end
end
