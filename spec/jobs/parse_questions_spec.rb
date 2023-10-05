require 'rails_helper'

RSpec.describe ParseQuestionsJob, type: :job do
  before(:all) do
    @repo = create(:repository, last_pull_at: DateTime.current)
    @build = create(:build, repository: @repo, aasm_state: :parsing_questions)
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    folder_directory = directory.join('Folder')
    FileUtils.mkdir_p(folder_directory)

    first_filepath = File.join(directory, 'article_one.md')
    article_one_content = <<~ARTICLE
      ---
      title: "First Article"
      date: "2023-10-02"
      author: "The Author"
      illustrator: "The Illustrator"
      questions:
        - ["one", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sit amet consectetur adipiscing elit pellentesque habitant morbi tristique senectus."]
        - ["two", "Habitant morbi tristique senectus et."]
      ---

      Article one content
    ARTICLE

    File.open(first_filepath, 'w') { |f| f.write(article_one_content) }

    second_filepath = File.join(directory, 'Folder', 'article_two.md')
    article_two_content = <<~ARTICLE
      ---
      title: "Second Article"
      date: "2023-10-03"
      author: "The Author"
      illustrator: "The Illustrator"
      questions:
        - ["three", "Et ligula ullamcorper malesuada proin libero. Ullamcorper sit amet risus nullam."]
        - ["four", "Adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus."]
      ---

      Article two content
    ARTICLE
    File.open(second_filepath, 'w') { |f| f.write(article_two_content) }
  end

  it 'queues the job' do
    ParseQuestionsJob.perform_async(@build.id)
    expect(ParseQuestionsJob).to have_enqueued_sidekiq_job(@build.id)
  end

  context 'when executing the job' do
    before(:all) do
      Sidekiq::Testing.inline! do
        ParseQuestionsJob.perform_async(@build.id)
      end
    end

    it 'creates questions associated with the first article' do
      questions = Question.where(page_path: 'article_one')
      expect(questions.count).to eq(2)
    end

    it 'creates questions associated with the second article' do
      questions = Question.where(page_path: 'Folder/article_two')
      expect(questions.count).to eq(2)
    end
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author.github_username)
    directory = parent_directory.join(@repo.name)
    FileUtils.remove_dir(directory)
    FileUtils.remove_dir(parent_directory)
  end
end
