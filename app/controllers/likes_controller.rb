class LikesController < ApplicationController
  before_action :authenticate_user!

  # POST /likes
  def create
    @like = current_user.likes.build(like_params)
    @like.save
    redirect_to answers_path(question)
  end

  # DELETE /likes/:id
  def destroy
    @like = Like.find(params[:id])
    @like.destroy
    redirect_to answers_path(question)
  end

  private

  def like_params
    params.require(:like).permit(:answer_id)
  end

  def question
    @like.answer.question
  end
end
