class RemoveDirectoryJob
  include Sidekiq::Job

  def perform(directory_path)
    FileUtils.rm_r(directory_path) if Dir.exist?(directory_path)
  end
end
