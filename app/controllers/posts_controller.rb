class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def by_user
    @user = User.find(params[:id])
    if @user
      @posts = @user.posts
    else
      redirect_to root_url
    end
  end

  def index
    @posts = Post.all
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      flash[:notice] = "Post created!"
      redirect_to @post
    else
      flash.now[:alert] = "Unable to create post!"
      render 'new'
    end
  end

  def update
      edit_params =params.require(:post).permit(:caption)
      if @post.update(edit_params)
        flash[:notice] = "Post updated!"
        redirect_to @post
      else
        flash[:alert] = "Unable to update post!"
        render 'edit'
      end
  end


  def destroy
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully destroyed.'
  end
  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:image, :caption)
    end
end
