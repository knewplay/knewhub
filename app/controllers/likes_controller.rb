class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @like = current_user.likes.build(like_params)
    @like.save
    redirect_to answers_path(@like.answer.question)
  end

  private

  def like_params
    params.require(:like).permit(:answer_id)
  end
end
