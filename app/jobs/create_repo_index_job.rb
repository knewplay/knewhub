class CreateRepoIndexJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    build = Build.find(build_id)
    if index_file_exists?(directory)
      build.logs.create(content: 'index.md file exists for this repository.')
    else
      generate_index_file(directory, repository)
      build.logs.create(content: 'index.md file successfully generated.')
    end
  end

  def index_file_exists?(directory)
    File.exist?("#{directory}/index.md")
  end

  # Returns array in the following format: [ "folder/filename", "folder/second%20folder/file_name" ]
  def list_markdown_file_location(directory)
    paths_array = Dir.glob("#{directory}/**/*.md")
    paths_array.map! do |path|
      path.remove("#{directory}/", '.md').downcase
    end
  end

  # Returns string in the following format:
  # "* [Folder/Filename](./folder/filename)
  #  * [Folder/Second Folder/File Name](.folder/second%20folder/file_name)"
  def generate_links(markdown_files_location, content = '')
    markdown_files_location.map do |file_location|
      filename = file_location.titleize
      content << "* [#{filename}](./#{file_location.gsub(/\s/, '%20')})\n"
    end
    content
  end

  def generate_front_matter(repository)
    <<~CONTENT
      ---
      title: #{repository.title.titleize}
      date: #{repository.last_pull_at.to_date}
      author: #{repository.author.name}
      ---
    CONTENT
  end

  def generate_index_file(directory, repository)
    markdown_files_location = list_markdown_file_location(directory)
    links = generate_links(markdown_files_location)
    front_matter = generate_front_matter(repository)
    content = "#{front_matter}\n#{links}"

    filepath = File.join(directory, 'index.md')
    File.open(filepath, 'w') { |f| f.write(content) }
  end
end
