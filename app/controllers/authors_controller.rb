class AuthorsController < ApplicationController
  before_action :require_author_authentication, :set_author

  def show; end

  def edit; end

  def update
    if @author.update(author_params)
      redirect_to author_path, notice: 'Author was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_author
    @author = Author.find(current_author.id)
  end

  def author_params
    params.require(:author).permit(:name)
  end
end
