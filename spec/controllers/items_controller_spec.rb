require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  before do
    allow(UserMailer).to \
      receive_message_chain(:account_activation, :deliver_now)
    allow(controller).to receive(:set_locale)
    allow(controller).to receive(:authenticate!)
    allow(controller).to receive(:authorized?)
  end

  describe 'GET #index' do
    let(:user) { create(:user_with_items) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :index, params: { user_id: user }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user_with_items) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :show, params: { user_id: user, id: user.items.first }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :new, params: { user_id: user }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'should renders index' do
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user_with_items) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :edit, params: { user_id: user, id: user.items.first }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:item) { double(:item) }
    let(:item_params) {
      {
        name: 'item name',
        speech: 'item speech',
        category: 1,
        image_attributes: {
          image: build(:image),
          crop_x: 0,
          crop_y: 0,
          crop_w: 50,
          crop_h: 50
        }
      }
    }

    before do
      allow(user).to receive_message_chain(:items, :build).and_return(item)
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'with valid parameters' do
      before do
        allow(item).to receive(:save).and_return(true)
        post :create, params: { item: item_params, user_id: user.id }
      end

      it "redirects to user's items page" do
        expect(response).to redirect_to(user_items_url(user))
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      before do
        allow(item).to receive(:save).and_return(false)
        allow(item).to receive(:image=)
        allow(Image).to receive(:new).and_return(build(:private_image))
        post :create, params: { item: item_params, user_id: user }
      end

      it 'renders new' do
        expect(response).to render_template(:new)
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PUT #update' do
    let(:user) { create(:user_with_items) }
    let(:item) { user.items.first }
    let(:params) {
      {
        item: {
          name: 'new name',
          image_attributes: {
            id: item
          }
        },
        user_id: user,
        id: item
      }
    }

    before do
      allow(user).to receive_message_chain(:items, :find_by).and_return(item)
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'with valid parameters' do
      before do
        allow(item).to receive(:update).and_return(true)
        put :update, params: params
      end

      it "redirects to user's items page" do
        expect(response).to redirect_to(user_item_url(user, item))
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      before do
        allow(item).to receive(:update).and_return(false)
        put :update, params: params
      end

      it 'renders new' do
        expect(response).to render_template(:edit)
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user_with_items) }
    let(:item) { user.items.first }
    let(:params) {
      {
        user_id: user,
        id: item
      }
    }

    before do
      allow(user).to receive_message_chain(:items, :find_by).and_return(item)
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'with valid parameters' do
      before do
        allow(item).to receive(:destroy)
        delete :destroy, params: params
      end

      it "redirects to user's items page" do
        expect(response).to redirect_to(user_items_url(user))
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'GET #image' do
    let(:user) { create(:user_with_items) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :image, params: { user_id: user, id: user.items.first }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end
  end
end
