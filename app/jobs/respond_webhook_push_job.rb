class RespondWebhookPushJob
  include Sidekiq::Job

  def perform(build_id, uid, webhook_description)
    repository = Repository.find_by(uid:)
    build = Build.find(build_id)

    repository.update(description: webhook_description)
    build.logs.create(content: 'Repository description successfully updated from GitHub.')

    directory = repository.storage_path
    Dir.exist?(directory) ? build.finished_receiving_webhook('pull') : build.finished_receiving_webhook('clone')
  end
end
