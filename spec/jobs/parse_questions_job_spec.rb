require 'rails_helper'

RSpec.describe ParseQuestionsJob do
  before(:all) do
    @repo = create(:repository, last_pull_at: DateTime.current)
    @first_build = create(:build, repository: @repo, aasm_state: :parsing_questions)

    @destination_directory = @repo.storage_path
    source_directory = Rails.root.join('spec/fixtures/jobs/parse_questions/first_round')
    FileUtils.mkdir_p(@destination_directory)
    FileUtils.copy_entry(source_directory, @destination_directory)
  end

  after(:all) do
    parent_directory = Rails.root.join('repos', @repo.author_username)
    FileUtils.remove_dir(parent_directory)
  end

  it 'queues the job' do
    described_class.perform_async(@first_build.id)
    expect(described_class).to have_enqueued_sidekiq_job(@first_build.id)
  end

  context 'when executing the job once' do
    before(:all) do
      Sidekiq::Testing.inline! do
        described_class.perform_async(@first_build.id)
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

    it 'newly created questions have hidden == false' do
      questions = Question.all
      expect(questions.all? { |question| question.hidden == false }).to be true
    end

    context 'when executing the job a second time' do
      before(:all) do
        FileUtils.rm_r(@destination_directory)
        source_directory = Rails.root.join('spec/fixtures/jobs/parse_questions/second_round')
        FileUtils.copy_entry(source_directory, @destination_directory)

        @second_build = create(:build, repository: @repo, aasm_state: :parsing_questions)

        Sidekiq::Testing.inline! do
          described_class.perform_async(@second_build.id)
        end
      end

      it 'has the original number of questions' do
        expect(Question.count).to eq(4)
      end

      it 'shows the unchanged question in the article that remains' do
        question = Question.find_by(tag: 'two')
        expect(question.hidden).to be false
      end

      it 'hides the deleted question in the article that remains' do
        question = Question.find_by(tag: 'one')
        expect(question.hidden).to be true
      end

      it 'hides the deleted questions in the article that was deleted' do
        questions = Question.where(page_path: 'Folder/article_two')
        expect(questions.all? { |question| question.hidden == true }).to be true
      end

      context 'when executing the job a third time' do
        before(:all) do
          FileUtils.rm_r(@destination_directory)
          source_directory = Rails.root.join('spec/fixtures/jobs/parse_questions/third_round')
          FileUtils.copy_entry(source_directory, @destination_directory)

          @third_build = create(:build, repository: @repo, aasm_state: :parsing_questions)

          Sidekiq::Testing.inline! do
            described_class.perform_async(@third_build.id)
          end
        end

        it 'has the original number of questions' do
          expect(Question.count).to eq(4)
        end

        it 'shows the question that was added back' do
          question = Question.find_by(tag: 'one')
          expect(question.hidden).to be false
        end
      end
    end
  end
end
