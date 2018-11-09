require 'rails_helper'

RSpec.describe AccountActivationsController, type: :controller do
  before(:each) do
    allow(UserMailer).to \
      receive_message_chain(:account_activation, :deliver_now)
    allow(controller).to receive(:set_locale)
  end

  describe 'GET #edit' do
    shared_examples 'invalid_user_password_reset' do
      before do
        get :edit, params: { id: user.id, email: user.email }
      end

      it 'sets flash alert message' do
        expect(flash[:alert]).to be_present
      end

      it 'redirects to root url' do
        expect(response).to redirect_to(root_url)
      end
    end

    context 'inexistent user' do
      it_behaves_like 'invalid_user_password_reset' do
        let(:user) { build(:user, id: 1) }
      end
    end

    context 'valid activated user' do
      before do
        allow(User).to receive(:find_by).with(email: user.email)
          .and_return(user)
      end

      it_behaves_like 'invalid_user_password_reset' do
        let(:user) { create(:user, activated: true) }
      end
    end

    context 'user with invalid authentic token' do
      let(:invalid_user) { create(:user) }

      before do
        allow(invalid_user).to receive(:authentic_token?)
          .with(:activation, invalid_user.id.to_s).and_return(false)
        allow(User).to receive(:find_by).with(email: invalid_user.email)
          .and_return(invalid_user)
      end

      it_behaves_like 'invalid_user_password_reset' do
        let(:user) { invalid_user }
      end
    end

    context 'valid unactivated user' do
      let(:user) { create(:user) }

      before do
        allow(user).to receive(:authentic_token?)
          .with(:activation, user.id.to_s).and_return(true)
        allow(user).to receive(:activate) { user.activated = true }
        allow(User).to receive(:find_by).with(email: user.email)
          .and_return(user)
        allow(controller).to receive(:log_in)
        get :edit, params: { id: user.id, email: user.email }
      end

      it 'activates the user' do
        expect(user).to be_activated
      end

      it 'sets flash success message' do
        expect(flash[:success]).to be_present
      end

      it 'redirects to user sppreadsheet url' do
        expect(response).to redirect_to(user_spreadsheets_path(user))
      end
    end
  end
end
