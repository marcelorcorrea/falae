require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:params) {
    {
      user: {
        email: user.email,
        password: user.password
      }
    }
  }

  describe 'GET #new' do
    before do
      allow(UserMailer).to \
        receive_message_chain(:account_activation, :deliver_now)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:set_locale)
      get :new
    end

    context 'logged in user' do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
      end

      it "redirects to user's spreadsheets page" do
        expect(response).to redirect_to(user_spreadsheets_path(user))
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'POST #create' do
    before do
      allow(UserMailer).to \
        receive_message_chain(:account_activation, :deliver_now)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:set_locale)
    end

    context 'authenticated user' do
      before do
        allow(User).to receive(:find_by).and_return(user)
      end

      context 'activated user' do
        before do
          allow(user).to receive(:activated?).and_return(true)
          allow(controller).to receive(:log_in)
          post :create, params: params
        end

        it "redirects to user's spreadsheets page" do
          expect(response).to redirect_to(user_spreadsheets_path(user))
        end

        it 'responds with redirect status' do
          expect(response).to have_http_status(:redirect)
        end
      end

      context 'not activated user' do
        before do
          allow(user).to receive(:activated?).and_return(false)
          post :create, params: params
        end

        it 'sets flash warning message' do
          expect(flash[:warning]).to be_present
        end

        it "renders new" do
          expect(response).to render_template('new')
        end

        it 'responds with success status' do
          expect(response).to be_successful
        end
      end
    end

    context 'inexistent user or unauthenticated user' do
      before do
        allow(User).to receive(:find_by).and_return(nil)
        post :create, params: params
      end

      it 'sets flash alert message' do
        expect(flash[:alert]).to be_present
      end

      it 'renders new' do
        expect(response).to render_template('new')
      end

      it 'responds with success status' do
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(controller).to receive(:log_out).and_return(true)
      delete :destroy
    end

    it 'redirects to root path' do
      expect(response).to redirect_to(root_path)
    end
  end
end
