class ParseQuestionsJob
  include Sidekiq::Job
  include ExtractFrontMatterHelper

  def perform(build_id)
    build = Build.find(build_id)
    repository, directory = RepositoryDirectory.define(build.repository.id)
    batch_code = SecureRandom.uuid

    markdown_files = list_markdown_absolute_path_and_page_name(directory)
    markdown_files.each do |absolute_path, page_name|
      perform_for_each_file(absolute_path, page_name, repository, batch_code)
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

  def perform_for_each_file(absolute_path, page_name, repository, batch_code)
    questions = extract_questions(absolute_path)
    parse_questions(repository, batch_code, questions, page_name) if questions
    hide_old_questions(repository, batch_code)
  end

  def extract_questions(absolute_path)
    front_matter = extract_front_matter(absolute_path)
    questions_array = front_matter['questions']

    questions_array&.inject(:merge!)
  end

  def parse_questions(repository, batch_code, questions, page_name)
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
end
