class RemoveRepoJob
  include Sidekiq::Job

  def perform(storage_path)
    FileUtils.rm_r(storage_path) if Dir.exist?(storage_path)
  end
end
