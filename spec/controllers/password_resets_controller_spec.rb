require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  before do
    allow(UserMailer).to \
      receive_message_chain(:account_activation, :deliver_now)
    allow(controller).to receive(:authenticate!)
    allow(controller).to receive(:authorized?)
    allow(controller).to receive(:set_locale)
  end

  describe 'GET #new' do
    before do
      get :new
    end

    it 'responds with success' do
      expect(response).to be_successful
    end

    it 'renders new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:email) { user.email }

    before do
      allow(user).to receive(:create_reset_digest)
      allow(user).to receive(:send_password_reset_email)
      allow(User).to receive(:find_by).with(email: email).and_return(user)
    end

    context 'with activated user' do
      before do
        allow(user).to receive(:activated?).and_return(true)
        post :create, params: { password_reset: { email: email } }
      end

      it 'creates a reset digest for user' do
        expect(user).to have_received(:create_reset_digest)
      end

      it 'sends an email to user' do
        expect(user).to have_received(:send_password_reset_email)
      end

      it 'sets flash warning message' do
        expect(flash[:warning]).to be_present
      end

      it 'redirects to the root page' do
        expect(response).to redirect_to(root_url)
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with unactivated user' do
      before do
        allow(user).to receive(:activated?).and_return(false)
        post :create, params: { password_reset: { email: email } }
      end

      it "doesn't create a reset digest for user" do
        expect(user).to_not have_received(:create_reset_digest)
      end

      it "doesn't send an email to user" do
        expect(user).to_not have_received(:send_password_reset_email)
      end

      it 'sets flash warning message' do
        expect(flash[:warning]).to be_present
      end

      it 'redirects to the root page' do
        expect(response).to redirect_to(root_url)
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  shared_examples 'invalid user' do
    it 'sets flash alert message' do
      expect(flash[:alert]).to be_present
    end

    it 'redirects to the root page' do
      expect(response).to redirect_to(root_url)
    end

    it 'responds with redirect status' do
      expect(response).to have_http_status(:redirect)
    end
  end

  shared_examples 'expired reset token' do
    it 'sets flash alert message' do
      expect(flash[:alert]).to be_present
    end

    it 'redirects to new reset password page' do
      expect(response).to redirect_to(new_password_reset_url)
    end

    it 'responds with redirect status' do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }
    let(:email) { user.email }

    context 'valid user and with token not expired' do
      before do
        allow(User).to receive(:find_by).with(email: email).and_return(user)
        allow(controller).to receive(:valid_user_password_reset)
        allow(controller).to receive(:check_expiration)
        get :edit, params: { id: user, email: email }
      end

      it 'renders edit' do
        expect(response).to render_template(:edit)
      end

      it 'responds with success status' do
        expect(response).to be_successful
      end
    end

    context 'invalid user' do
      before do
        allow(User).to receive(:find_by).with(email: email).and_return(nil)
        get :edit, params: { id: user, email: email }
      end

      it_behaves_like 'invalid user'
    end

    context 'with expired reset token' do
      before do
        allow(User).to receive(:find_by).with(email: email).and_return(user)
        allow(controller).to receive(:valid_user_password_reset)
          .and_return(true)
        allow(user).to receive(:password_reset_expired?).and_return(true)
        get :edit, params: { id: user, email: email }
      end

      it_behaves_like 'expired reset token'
    end
  end

  describe 'PUT #update' do
    let(:user) { create(:user) }
    let(:email) { user.email }

    context 'valid user and with token not expired' do
      before do
        allow(User).to receive(:find_by).and_return(user)
        allow(controller).to receive(:valid_user_password_reset)
        allow(controller).to receive(:check_expiration)
      end

      context 'valid parameters' do
        before do
          allow(user).to receive(:update).and_return(true)
          allow(controller).to receive(:log_in)
          put :update, params: {
            id: user,
            email: email,
            user: {
              password: 'password',
              password_confirmation: 'password'
            }
          }
        end

        it 'sets flash success message' do
          expect(flash[:success]).to be_present
        end

        it 'redirects to new reset password page' do
          expect(response).to redirect_to(user_spreadsheets_path(user))
        end

        it 'responds with redirect status' do
          expect(response).to have_http_status(:redirect)
        end
      end

      context 'invalid parameters' do
        before do
          allow(user).to receive(:update).and_return(false)
          put :update, params: {
            id: user,
            email: email,
            user: {
              password: 'password',
              password_confirmation: 'password'
            }
          }
        end

        it 'renders edit' do
          expect(response).to render_template(:edit)
        end

        it 'responds with success status' do
          expect(response).to be_successful
        end
      end

    end

    context 'invalid user' do
      before do
        allow(User).to receive(:find_by).with(email: email).and_return(nil)
        allow(user).to receive(:activated?).and_return(true)
        allow(user).to receive(:authentic_token?).with(:reset, user.id.to_s)
          .and_return(true)
        put :update, params: { id: user, email: email }
      end

      it_behaves_like 'invalid user'
    end

    context 'with expired reset token' do
      before do
        allow(User).to receive(:find_by).with(email: email).and_return(user)
        allow(controller).to receive(:valid_user_password_reset)
          .and_return(true)
        allow(user).to receive(:password_reset_expired?).and_return(true)
        put :update, params: { id: user, email: email }
      end

      it_behaves_like 'expired reset token'
    end
  end
end
