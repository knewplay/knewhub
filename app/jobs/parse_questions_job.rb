class ParseQuestionsJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository, directory = RepositoryDirectory.define(build.repository.id)
    batch_code = SecureRandom.uuid

    markdown_files = list_markdown_absolute_path_and_page_name(directory)
    markdown_files.each do |absolute_path, page_name|
      parse_questions(repository, batch_code, absolute_path, page_name)
      hide_old_questions(repository, batch_code)
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

  def parse_questions(repository, batch_code, absolute_path, page_name)
    front_matter = extract_front_matter(absolute_path)
    return if front_matter['questions'].nil?

    questions = front_matter['questions'].inject(:merge!)
    questions.each do |tag, body|
      question = Question.find_by(repository:, tag:, page_path: page_name)
      if question.nil?
        Question.create(repository:, tag:, page_path: page_name, body:, batch_code:)
      else
        question.update(body:, batch_code:)
      end
    end
  end

  def hide_old_questions(repository, current_batch_code)
    repositories_questions = repository.questions
    repositories_questions.each do |question|
      if question.batch_code == current_batch_code
        question.update(hidden: false)
      else
        question.update(hidden: true)
      end
    end
  end

  def extract_front_matter(file_path)
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date])
    FrontMatterParser::Parser.parse_file(file_path, loader:).front_matter
  end
end
