require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before do
    allow(UserMailer).to \
      receive_message_chain(:account_activation, :deliver_now)
  end

  context 'GET #new' do
    before do
      allow(controller).to receive(:set_locale)
      get :new
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end
  end

  context 'POST #create' do
    let(:user) { double(:user) }
    let(:user_params) {
      {
        name: 'user name',
        last_name: 'user last name',
        email: 'user_email@falae.com',
        email_confirmation: 'user_email@falae.com',
        password: 'user password',
        password_confirmatio: 'user password',
        locale: 'user locale'
      }
    }

    before do
      allow(controller).to receive(:set_locale)
    end

    context 'with valid parameters' do
      before do
        allow(user).to receive(:save).and_return(true)
        allow(User).to receive(:new).and_return(user)
        post :create, params: { user: user_params }
      end

      it 'sets flash alert message' do
        expect(flash[:warning]).to be_present
      end

      it 'redirects to users root url' do
        expect(response).to redirect_to(root_url)
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      before do
        allow(user).to receive(:save).and_return(false)
        allow(user).to receive(:photo=)
        allow(User).to receive(:new).and_return(user)
        post :create, params: { user: user_params }
      end

      it 'sets user photo to nil' do
        expect(user).to have_received(:photo=).with(nil)
      end

      it 'renders new' do
        expect(response).to render_template('new')
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'Unautheticated user' do
    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:set_locale)
      allow(controller).to receive(:logged_in?).and_return(false)
      allow(controller).to receive(:user_from_token_authentication)
        .and_return(false)
      get :show, params: { id: user.id }
    end

    it 'redirects to root page' do
      expect(response).to redirect_to(root_url)
    end

    it 'responds with redirect status' do
      expect(response).to have_http_status(:redirect)
    end
  end

  context 'Autheticated user' do
    let(:available_locales) { [:en] }
    let(:user) { create(:user, locale: available_locales.first) }

    before do
      allow(controller).to receive(:authenticate!).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      allow(I18n).to receive(:available_locales).and_return(available_locales)
    end

    describe 'GET #show' do
      context 'Authorized user' do
        before do
          allow(controller).to receive(:authorized?).and_return(true)
          get :show, params: { id: user.id }
        end

        it 'sets app locale to user locale' do
          expect(I18n.locale.to_s).to eq(user.locale)
        end

        it 'renders the about template' do
          expect(response).to render_template('show')
        end

        it 'responds with success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'Unauthorized user' do
        let(:other_user) { create(:user) }

        before do
          allow(controller).to receive(:set_locale)
        end

        context 'html requests' do
          before do
            get :show, params: { id: other_user.id }
          end

          it "redirects to user's root url" do
            expect(response).to redirect_to(root_url)
          end

          it 'responds with redirect status' do
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'json requests' do
          before do
            get :show, params: { id: other_user.id }, format: :json
          end

          it 'responds with Access Denied' do
            expect(response.body).to eq('{"error":"Access Denied"}')
          end

          it 'responds with unauthorized status' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end

    describe 'PUT #update' do
      context 'Authorized user' do
        before do
          allow(controller).to receive(:authorized?).and_return(true)
          allow(controller).to receive(:set_locale)
        end

        context 'with valid parameters' do
          before do
            allow(user).to receive(:update).and_return(true)
            allow(I18n).to receive(:locale=)
            put :update, params: { user: { locale: :en }, id: user.id }
          end

          it 'updates locale to user locale' do
            expect(I18n).to have_received(:locale=).with(user.locale)
          end

          it "redirects to user's page" do
            expect(response).to redirect_to(user)
          end

          it 'sets notice message' do
            expect(flash[:notice]).to be_present
          end

          it 'responds with redirect status' do
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'with invalid parameters' do
          before do
            allow(user).to receive(:update).and_return(false)
            put :update, params: { user: { locale: :en }, id: user.id }
          end

          it "redirects to user's page" do
            expect(response).to render_template('edit')
          end

          it 'responds with redirect status' do
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    describe 'GET #photo' do
      context 'Authorized user' do
        before do
          allow(controller).to receive(:authorized?).and_return(true)
          allow(controller).to receive(:set_locale)
          allow(controller).to receive(:send_file)
          get :photo, params: { id: user.id }, format: :json
        end

        it 'sends the user photo' do
          expect(controller).to have_received(:send_file)
        end
      end
    end

    describe 'GET #change_email' do
      context 'Authorized user' do
        before do
          allow(controller).to receive(:authorized?).and_return(true)
          allow(controller).to receive(:set_locale)
          get :change_email, params: { id: user.id }
        end

        it "renders the view to change user's email" do
          expect(response).to render_template('change_email')
        end

        it 'responds with success status' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'GET #change_password' do
      context 'Authorized user' do
        before do
          allow(controller).to receive(:authorized?).and_return(true)
          allow(controller).to receive(:set_locale)
          get :change_password, params: { id: user.id }
        end

        it "renders the view to change user's email" do
          expect(response).to render_template('change_password')
        end

        it 'responds with success status' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'PATCH #change_email' do
      context 'Authorized user' do
        before do
          allow(controller).to receive(:authorized?).and_return(true)
          allow(controller).to receive(:set_locale)
        end

        context 'incorrect password' do
          let(:params) {
            {
              user: {
                email: 'new_email@falae.com',
                email_confirmation: 'new_email@falae.com',
                password: 'wrong password'
              },
              id: user.id
            }
          }

          before do
            allow(user).to receive(:authenticate!)
              .with(params[:user][:password], :password).and_return(false)
            patch :update_email, params: params
          end

          it 'sets alert message' do
            expect(flash.now[:alert]).to be_present
          end

          it "renders the user's email change view" do
            expect(response).to render_template('change_email')
          end

          it 'responds with success status' do
            expect(response).to have_http_status(:success)
          end
        end

        context 'correct password and valid new email' do
          let(:params) {
            {
              user: {
                email: 'new_email@falae.com',
                email_confirmation: 'new_email@falae.com',
                password: user.password
              },
              id: user.id
            }
          }

          before do
            allow(user).to receive(:authenticate!)
              .with(params[:user][:password], :password).and_return(true)
            allow(user).to receive(:update).and_return(true)
            patch :update_email, params: params
          end

          it 'sets error message' do
            expect(flash[:notice]).to be_present
          end

          it "redirects to user's page" do
            expect(response).to redirect_to(user)
          end

          it 'responds with success redirect' do
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'correct password and invalid new email' do
          let(:params) {
            {
              user: {
                email: 'invalida_new_email',
                email_confirmation: 'invalida_new_email',
                password: user.password
              },
              id: user.id
            }
          }

          before do
            allow(user).to receive(:authenticate!)
              .with(params[:user][:password], :password).and_return(true)
            allow(user).to receive(:update).and_return(false)
            patch :update_email, params: params
          end

          it 'sets alert message' do
            expect(flash.now[:alert]).to be_present
          end

          it "renders the user's email change view" do
            expect(response).to render_template('change_email')
          end

          it 'responds with success status' do
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    describe 'PATCH #change_password' do
      context 'Authorized user' do
        before do
          allow(controller).to receive(:authorized?).and_return(true)
          allow(controller).to receive(:set_locale)
        end

        context 'incorrect password' do
          let(:params) {
            {
              user: {
                password: 'new_password',
                password_confirmation: 'new_password',
                current_password: 'incorrect password'
              },
              id: user.id
            }
          }

          before do
            allow(user).to receive(:authenticate!)
              .with(params[:user][:current_password], :current_password)
              .and_return(false)
            patch :update_password, params: params
          end

          it 'sets alert message' do
            expect(flash.now[:alert]).to be_present
          end

          it "renders the user's password change view" do
            expect(response).to render_template('change_password')
          end

          it 'responds with success status' do
            expect(response).to have_http_status(:success)
          end
        end

        context 'correct password and valid new password' do
          let(:params) {
            {
              user: {
                password: 'new_password',
                password_confirmation: 'new_password',
                current_password: user.password
              },
              id: user.id
            }
          }

          before do
            allow(user).to receive(:authenticate!)
              .with(params[:user][:current_password], :current_password)
              .and_return(true)
            allow(user).to receive(:update).and_return(true)
            patch :update_password, params: params
          end

          it 'sets notice message' do
            expect(flash[:notice]).to be_present
          end

          it "redirects to user's page" do
            expect(response).to redirect_to(user)
          end

          it 'responds with success redirect' do
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'correct password and invalid new password' do
          let(:params) {
            {
              user: {
                password: 'inv', # less than 6 character
                password_confirmation: 'inv',
                current_password: user.password
              },
              id: user.id
            }
          }

          before do
            allow(user).to receive(:authenticate!)
              .with(params[:user][:current_password], :current_password)
              .and_return(true)
            allow(user).to receive(:update).and_return(false)
            patch :update_password, params: params
          end

          it 'sets alert message' do
            expect(flash.now[:alert]).to be_present
          end

          it "renders the user's password change view" do
            expect(response).to render_template('change_password')
          end

          it 'responds with success status' do
            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end
end
