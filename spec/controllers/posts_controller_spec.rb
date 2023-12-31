# rubocop:disable all

require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, role: 'admin') }

  let(:post) { create(:post, user:) }

  describe 'GET #new' do
    before { sign_in_user(user) }

    it 'assigns a new post to @post' do
      get :new, params: { user_id: user.id }
      expect(assigns(:post)).to be_a_new(Post)
      expect(assigns(:post).user).to eq(user)
    end

    it 'renders the new template' do
      get :new, params: { user_id: user.id }
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #show' do
    before { sign_in_user(user) }

    it 'assigns the correct post to @post' do
      get :show, params: { id: post.id }
      expect(assigns(:post)).to eq(post)
    end

    it 'assigns the post user to @user' do
      get :show, params: { id: post.id }
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns connected friends to @friends' do
      friend = create(:user)
      create(:friendship, user:, friend:, connected: true)

      get :show, params: { id: post.id }
      expect(assigns(:friends)).to eq([friend])
    end

    it 'assigns a new comment to @comment' do
      get :show, params: { id: post.id }
      expect(assigns(:comment)).to be_a_new(Comment)
    end

    it 'renders the show template' do
      get :show, params: { id: post.id }
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in_user(user) }

    it 'destroys the post' do
      post

      expect do
        delete :destroy, params: { id: post.id }
      end.to change(Post, :count).by(-1)
    end

    it 'destroys associated likes and comments' do
      like = create(:like, post:)
      comment = create(:comment, post:)

      expect do
        delete :destroy, params: { id: post.id }
      end.to change(Like, :count).by(-1)
                                 .and change(Comment, :count).by(-1)
    end

    it 'redirects to home_users_path with success message' do
      delete :destroy, params: { id: post.id }
      expect(response).to redirect_to(home_users_path)
      expect(flash[:notice]).to eq('Post deleted successfully.')
    end
  end

  describe 'POST #approve' do
    let(:post_to_approve) { create(:post, user: user) }

    before { sign_in_user(admin_user) }

    it 'approves a post when called by an admin' do
      post_to_approve.update(status: 'approved')
      post_to_approve.reload
      expect(post_to_approve.status).to eq('approved')
    end
  end

  describe 'POST #reject' do
    let(:post_to_reject) { create(:post, user: user) }

    before { sign_in_user(admin_user) }

    it 'rejects a post when called by an admin' do
      post_to_reject.update(status: 'rejected')
      post_to_reject.reload
      expect(post_to_reject.status).to eq('rejected')
    end
  end

  def sign_in_user(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
