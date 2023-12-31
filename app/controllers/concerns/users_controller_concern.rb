# frozen_string_literal: true

module UsersControllerConcern
  extend ActiveSupport::Concern
  include UsersHelper

  included do
    before_action :require_login, only: %i[home profile delete_account show]
    before_action :require_admin, only: %i[users_list show], except: %i[connect disconnect connections]
  end

  def profiles
    if User.exists?(params[:id])
      if User.find(params[:id]) == current_user
        render :profile
      else
        @user = User.find(params[:id])
      end
    else
      redirect_to home_users_path, alert: "User doesn't exist"
    end
  end

  def profile
    return unless current_user.nil?

    redirect_to root_path, notice: 'Please login to access this page'
  end

  def users_list
    @users = User.where(role: 'user')
    render 'users/users_list'
  end

  def home
    @posts = Post.all

    @users = User.where(role: 'user')
    return unless current_user.nil?

    redirect_to root_path, notice: 'Please login to access this page'
  end

  def connect
    @user = User.find(params[:id])
    if user_already_connected?
      flash[:notice] = 'Already connected!'
    else
      create_or_update_friendship
      send_connect_notification(@user)
      flash[:notice] = 'Friendship request sent!'
    end
    render :profiles
  end

  def disconnect
    @user = User.find(params[:id])
    friendship = find_friendship
    destroy_friendship(friendship)
    flash[:notice] = 'Successfully disconnected!'
    send_disconnect_notification(@user)
    redirect_after_disconnect
  end

  def connections
    @user = current_user
    redirect_to home_users_path, notice: 'Access denied. Admins can\'t perform this action.' if current_user&.admin?
    @friends = @user.friends.where(friendships: { connected: true })
    @pending_requests = Friendship.where(friend_id: @user.id, connected: false)
    @requests = @user.friends.where(friendships: { connected: false })
  end

  def report
    @user = User.find(params[:id])
    @user.increment(:report)
    @user.save
    flash[:notice] = 'User reported successfully.'
    redirect_to @user
  end

  def remove_cv
    current_user.cv&.purge
    redirect_to profile_users_path, notice: 'CV removed successfully!'
  end

  def edit_password
    @user = current_user
  end

  def update_password
    if current_user.update(password_params)
      flash[:notice] = 'Password updated successfully.'
      redirect_to root_path
    else
      flash[:alert] = current_user.errors.full_messages.map { |message| "• #{message}" }.join('<br>').html_safe
      render :edit_password
    end
  end

  def search
    query = params[:query].gsub(/[^\w\s]/, '')
    @users = if query.present?
               User.search_items(query).records.where.not(role: 'admin')
             else
               User.where.not(role: 'admin')
             end
  end
end
