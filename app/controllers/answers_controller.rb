class AnswersController < ApplicationController
  before_action :set_question, :authenticate_user!

  def index
    @answers = @question.answers
  end

  def new
    @answer = @question.answers.build
  end

  def create
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user
    if @answer.save
      redirect_to answers_path(@question.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy
    redirect_to answers_path(@question.id)
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
