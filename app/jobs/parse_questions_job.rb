class ParseQuestionsJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    build = Build.find(build_id)

    markdown_files = list_markdown_absolute_path_and_page_name(directory)
    markdown_files.each do |absolute_path, page_name|
      parse_questions(repository, absolute_path, page_name)
    end
    build.logs.create(content: 'Questions successfully parsed.')
    build.finished_parsing_questions
  end

  private

  def list_markdown_absolute_path_and_page_name(directory)
    absolute_paths = Dir.glob("#{directory}/**/*.md")
    absolute_paths.map! do |path|
      [path, path.remove("#{directory}/", '.md')]
    end
  end

  def parse_questions(repository, absolute_path, page_name)
    front_matter = extract_front_matter(absolute_path)
    front_matter['questions']&.each do |tag, body|
      Question.find_or_create_by(
        repository:,
        tag:,
        body:,
        page_path: page_name
      )
    end
  end

  def extract_front_matter(file_path)
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date])
    FrontMatterParser::Parser.parse_file(file_path, loader:).front_matter
  end
end
