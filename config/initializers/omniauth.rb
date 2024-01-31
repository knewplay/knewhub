OmniAuth.config.logger = Logger.new(STDOUT)
OmniAuth.config.logger.progname = "omniauth"
OmniAuth.config.logger.formatter = proc do |severity, _time, progname, msg|
  "#{severity}: #{progname}: #{msg}\n"
end
