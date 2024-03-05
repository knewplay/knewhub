class UploadAutodeskFileJob
  include Sidekiq::Job

  def perform(repository_id, filepath)
    autodesk_file = AutodeskFile.create!(repository_id:, filepath:)
    urn = Autodesk.new.upload_file_for_viewer(filepath)

    return if urn.nil?

    autodesk_file.update(urn:)
  end
end

# Update this job to use build_id and update build logs
