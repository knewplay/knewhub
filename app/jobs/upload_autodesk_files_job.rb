class UploadAutodeskFilesJob
  include Sidekiq::Job
  include SplitMarkdownHelper

  # Update this job to use build_id and update build logs
  def perform(build_id)
    build = Build.find(build_id)
    _repository, directory = RepositoryDirectory.define(build.repository.id)

    autodesk_files = list_autodesk_files_for_directory(directory)

    if autodesk_files.empty?
      build.logs.create(content: 'No Autodesk files were found in this repository.')
    else
      build.logs.create(content: 'Autodesk files found in this repository. Uploading...')
      autodesk_files.each do |filepath|
        perform_for_each_file(build, build.repository.id, filepath)
      end
    end

    build.finished_uploading_autodesk_files
  end

  private

  def list_markdown_file_paths(directory)
    Dir.glob("#{directory}/**/*.md")
  end

  def list_autodesk_files_for_markdown_file(markdown_file_path)
    markdown_path_name = Pathname.new(markdown_file_path)
    directory_path_name = markdown_path_name.dirname

    _front_matter, markdown_content = split_markdown(markdown_file_path)
    autodesk_file_relative_paths = markdown_content.scan(/\[3d-viewer (.+)\]/).flatten
    # ["./3d-files/nist_ctc_01_asme1_rd.stp", "./3d-files/nist_ctc_02_asme1_rc.stp""]

    return if autodesk_file_relative_paths.empty?

    autodesk_file_relative_paths.map do |relative_path|
      directory_path_name.join(relative_path).relative_path_from(Rails.root).to_s
    end
    # ["repos/author/repo_owner/name/chapter-1/3d-files/nist_ctc_01_asme1_rd.stp",
    #  "repos/author/repo_owner/name/chapter-1/3d-files/nist_ctc_02_asme1_rc.stp"]
  end

  def list_autodesk_files_for_directory(directory, autodesk_files = [])
    markdown_file_paths = list_markdown_file_paths(directory)
    markdown_file_paths.each do |markdown_file_path|
      autodesk_files_for_markdown_file = list_autodesk_files_for_markdown_file(markdown_file_path)
      autodesk_files << autodesk_files_for_markdown_file if autodesk_files_for_markdown_file
    end
    autodesk_files = autodesk_files.flatten
  end

  def perform_for_each_file(build, repository_id, filepath)
    autodesk_file = AutodeskFile.create!(repository_id:, filepath:)
    autodesk_service = Autodesk.new(build)
    urn = autodesk_service.upload_file_for_viewer(filepath)

    return if urn.nil?

    autodesk_file.update(urn:)
  end
end
