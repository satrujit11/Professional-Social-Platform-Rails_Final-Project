# frozen_string_literal: true

class LikesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    existing_like = @post.likes.find_by(user_id: current_user.id)

    if existing_like
      existing_like.destroy
      liked = false
    else
      @post.likes.create(user_id: current_user.id)
      liked = true
    end

    render json: { liked:, like_count: @post.likes.count }
  end

  def index
    @post = Post.find(params[:post_id])
    render json: { like_count: @post.likes.count }
  end
end
