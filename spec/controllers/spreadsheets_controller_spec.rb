require 'rails_helper'

RSpec.describe SpreadsheetsController, type: :controller do
  let(:user) { create(:user_with_pages) }

  before do
    allow(UserMailer).to \
      receive_message_chain(:account_activation, :deliver_now)
    allow(controller).to receive(:set_locale)
    allow(controller).to receive(:authenticate!)
    allow(controller).to receive(:authorized?)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    before do
      get :index, params: { user_id: user }
    end

    it 'responds with success' do
      expect(response).to be_successful
    end

    it 'renders index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    context 'user has the spreadsheet' do
      let(:spreadsheet) { user.spreadsheets.first }

      before do
        allow(user).to receive_message_chain(:spreadsheets, :first)
          .and_return(spreadsheet)
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(spreadsheet)
        get :show, params: { id: spreadsheet, user_id: user }
      end

      it 'responds with success' do
        expect(response).to be_successful
      end

      it 'renders show' do
        expect(response).to render_template(:show)
      end
    end

    context "user doesn1t have the spreadsheet" do
      let(:spreadsheet) { create(:spreadsheet) }
      before do
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(nil)
        get :show, params: { id: spreadsheet, user_id: user }
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end

      it 'renders user_spreadsheets_url' do
        expect(response).to redirect_to(user_spreadsheets_url(user))
      end
    end
  end

  describe 'GET #new' do
    before do
      get :new, params: { user_id: user }
    end

    it 'responds with success' do
      expect(response).to be_successful
    end

    it 'renders new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let(:spreadsheet) { user.spreadsheets.first }

    before do
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
      get :edit, params: { id: spreadsheet, user_id: user }
    end

    it 'responds with success' do
      expect(response).to be_successful
    end

    it 'renders edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:spreadsheet) { create(:spreadsheet) }
      let(:spreadsheet_params) {
        {
          name: spreadsheet.name,
          initial_page: spreadsheet.initial_page
        }
      }

      before do
        allow(spreadsheet).to receive(:save).and_return(true)
        allow(user).to receive_message_chain(:spreadsheets, :build)
          .and_return(spreadsheet)
        post :create, params: { spreadsheet: spreadsheet_params, user_id: user }
      end

      it "redirects to user's spreadsheet's page" do
        expect(response).to redirect_to(user_spreadsheet_url(user, spreadsheet))
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      let(:spreadsheet) { build(:spreadsheet) }
      let(:spreadsheet_params) {
        {
          name: nil,
          initial_page: spreadsheet.initial_page
        }
      }

      before do
        allow(spreadsheet).to receive(:save).and_return(false)
        allow(user).to receive_message_chain(:spreadsheets, :build)
          .and_return(spreadsheet)
        post :create, params: { spreadsheet: spreadsheet_params, user_id: user }
      end

      it 'renders new' do
        expect(response).to render_template(:new)
      end

      it 'responds with redirect status' do
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    let(:spreadsheet) { user.spreadsheets.first }

    before do
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
    end

    context 'with valid parameters' do
      let(:spreadsheet_params) {
        {
          name: 'spreadsheet new name',
          initial_page: spreadsheet.initial_page
        }
      }

      before do
        allow(spreadsheet).to receive(:update).and_return(true)
        put :update, params: {
          id: spreadsheet.id,
          spreadsheet: spreadsheet_params,
          user_id: user
        }
      end

      it "redirects to user's spreadsheet page" do
        expect(response).to redirect_to(user_spreadsheet_url(user, spreadsheet))
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      let(:spreadsheet_params) {
        {
          name: nil,
          initial_page: spreadsheet.initial_page
        }
      }

      before do
        allow(spreadsheet).to receive(:update).and_return(false)
        put :update, params: {
          id: spreadsheet.id,
          spreadsheet: spreadsheet_params,
          user_id: user
        }
      end

      it 'renders new' do
        expect(response).to render_template(:edit)
      end

      it 'responds with redirect status' do
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:spreadsheet) { user.spreadsheets.first }

    before do
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :destroy)
    end

    context 'with valid parameters' do
      before do
        delete :destroy, params: { id: spreadsheet.id, user_id: user }
      end

      it "redirects to user's spreadsheets page" do
        expect(response).to redirect_to(user_spreadsheets_url(user))
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
