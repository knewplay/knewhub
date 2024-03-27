class AnswersController < ApplicationController
  before_action :set_question, :authenticate_user!

  # GET /questions/:question_id/answers
  def index
    @answers = @question.answers.order(created_at: :desc)
  end

  # GET /questions/:question_id/answers/new
  def new
    @answer = @question.answers.build
  end

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user
    if @answer.save
      respond_to do |format|
        format.html { redirect_to answers_path(@question.id) }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /questions/:question_id/answers/:id
  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to answers_path(@question.id) }
      format.turbo_stream
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
