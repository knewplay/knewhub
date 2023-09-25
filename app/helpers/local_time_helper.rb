module LocalTimeHelper
  def local_time(date_time)
    return if date_time.nil?

    date_time.in_time_zone(cookies[:timezone] || 'UTC').strftime('%b %d, %Y %l:%M%P')
  end
end
