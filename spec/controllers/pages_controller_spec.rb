require 'rails_helper'

RSpec.describe PagesController, type: :controller do
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
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }

    before do
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
      get :index, params: { user_id: user, spreadsheet_id: spreadsheet }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    context 'spreadsheet and page are present' do
      let(:spreadsheet) { user.spreadsheets.first }
      let(:page) { spreadsheet.pages.first }

      before do
        allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(page)
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(spreadsheet)
        get :show, params: {
            id: page,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
      end

      it 'responds with success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders show' do
        expect(response).to render_template(:show)
      end
    end

    context "spreadsheet doesn't belong to user" do
      let(:spreadsheet) { user.spreadsheets.first }
      let(:page) { spreadsheet.pages.first }

      before do
        allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
        allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(nil)
        allow(user).to receive_message_chain(:spreadsheets, :first)
          .and_return(spreadsheet)
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(nil)
        get :show, params: {
            id: page,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
      end

      it 'responds with redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it "renders user's spreadsheets" do
        expect(response).to redirect_to(user_spreadsheets_url)
      end
    end

    context "has spreadsheet, but page doens't belong to spreadsheet" do
      let(:spreadsheet) { user.spreadsheets.first }
      let(:page) { create(:page) }

      before do
        allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
        allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(nil)
        allow(user).to receive_message_chain(:spreadsheets, :first)
          .and_return(spreadsheet)
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(spreadsheet)
        get :show, params: {
            id: page,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
      end

      it 'responds with redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'renders show' do
        expect(response).to redirect_to(user_spreadsheet_url(user, spreadsheet))
      end
    end
  end

  describe 'GET #new' do
    let(:spreadsheet) { user.spreadsheets.first }

    before do
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(spreadsheet)
      get :new, params: { user_id: user, spreadsheet_id: spreadsheet }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'should renders index' do
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }

    before do
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
      get :edit, params: {
            id: page,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
    end

    it 'responds with success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page_params) {
      {
        name: 'page name',
        columns: 'page columns',
        rows: 'page rows',
        spreadsheet: spreadsheet
      }
    }

    before do
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
    end

    context 'with valid parameters' do
      let(:page) { create(:page, spreadsheet: spreadsheet) }
      before do
        allow(spreadsheet).to receive_message_chain(:pages, :build)
          .and_return(page)
        allow(page).to receive(:save).and_return(true)
        post :create, params: {
            page: page_params,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
      end

      it "redirects to user's spreadsheet's page page" do
        url = user_spreadsheet_page_url(user, spreadsheet, page)
        expect(response).to redirect_to(url)
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      let(:page) { build(:page, spreadsheet: spreadsheet) }
      before do
        allow(spreadsheet).to receive_message_chain(:pages, :build)
          .and_return(page)
        allow(page).to receive(:save).and_return(false)
        post :create, params: {
            page: page_params,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
      end

      it 'renders new' do
        expect(response).to render_template(:new)
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PUT #update' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:page_params) {
      {
        name: 'page name',
        columns: 'page columns',
        rows: 'page rows',
        spreadsheet: spreadsheet
      }
    }

    before do
      allow(spreadsheet).to receive_message_chain(:pages, :first)
        .and_return(page)
      allow(spreadsheet).to receive_message_chain(:pages, :find_by)
        .and_return(page)
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
    end

    context 'with valid parameters' do
      before do
        allow(page).to receive(:save).and_return(true)
        put :update, params: {
            id: page,
            page: page_params,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
      end

      it "redirects to user's spreadsheet's page page" do
        url = user_spreadsheet_page_url(user, spreadsheet, page)
        expect(response).to redirect_to(url)
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
        allow(page).to receive(:save).and_return(false)
        put :update, params: {
            id: page,
            page: page_params,
            user_id: user,
            spreadsheet_id: spreadsheet
          }
      end

      it 'renders new' do
        expect(response).to render_template(:edit)
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:params) {
      {
        id: page,
        spreadsheet_id: spreadsheet,
        user_id: user,
      }
    }

    context 'with valid parameters' do
      before do
        allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
        allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(page)
        allow(spreadsheet).to receive_message_chain(:pages, :destroy)
        allow(user).to receive_message_chain(:spreadsheets, :first)
          .and_return(spreadsheet)
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(spreadsheet)
        delete :destroy, params: params
      end

      it "redirects to user's spreadsheets page" do
        url = user_spreadsheet_url(user, spreadsheet)
        expect(response).to redirect_to(url)
      end

      it 'sets flash notice message' do
        expect(flash[:notice]).to be_present
      end

      it 'responds with redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'GET #add_item' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }

    before do
      allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
      allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(page)
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
      get :add_item,
        params: {
          id: page,
          spreadsheet_id: spreadsheet,
          user_id: user,
        },
        xhr: true
    end

    it 'responds with success status' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #search_item' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:params) {
      {
        id: page,
        spreadsheet_id: spreadsheet,
        user_id: user
      }
    }

    before do
      allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
      allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(page)
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
    end

    context 'with name query search' do
      before do
        search_params = params.merge(search: true, name: 'name')
        get :search_item, params: search_params, xhr: true
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'without name query search' do
      before do
        get :search_item, params: params, xhr: true
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #add_to_page' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:params) {
      {
        id: page,
        spreadsheet_id: spreadsheet,
        user_id: user
      }
    }

    context 'adding a private item' do
      let(:item) { create(:item, user: user, image: create(:private_image))}

      before do
        allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
        allow(spreadsheet).to receive_message_chain(:pages, :find_by)
            .and_return(page)
        allow(user).to receive_message_chain(:spreadsheets, :first)
          .and_return(spreadsheet)
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(spreadsheet)
        params[:item] = { id: item.id }
        post :add_to_page, params: params, xhr: true
      end

      it 'responds with success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'adding a public item' do
      let(:item) { build(:item, image: create(:pictogram)) }
      before do
        allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
        allow(spreadsheet).to receive_message_chain(:pages, :find_by)
            .and_return(page)
        allow(user).to receive_message_chain(:spreadsheets, :first)
          .and_return(spreadsheet)
        allow(user).to receive_message_chain(:spreadsheets, :find_by)
          .and_return(spreadsheet)
        params[:item] = {
          name: item.name,
          speech: item.speech,
          category_id: item.category_id,
          image_attributes: {
            id: item.image.id
          }
        }
        post :add_to_page, params: params, xhr: true
      end

      it 'responds with success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #edit_item' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:item) { create(:item) }

    before do
      page.items << item
      allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
      allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(page)
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
      get :edit_item,
        params: {
          id: page,
          spreadsheet_id: spreadsheet,
          user_id: user,
          item_id: item.id
        },
        xhr: true
    end

    it 'responds with success status' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #update_item' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:item) { create(:item) }
    let(:item_page) {
      double(:item_page, id: 1, item_id: item.id, page_id: page.id)
    }
    let(:params) {
      {
        id: page,
        spreadsheet_id: spreadsheet,
        user_id: user,
        item: {
          id: item.id
        }
      }
    }

    before do
      page.items << item
      allow(item).to receive(:update)
      allow(ItemPage).to receive(:find_by).and_return(item_page)
      allow(page).to receive_message_chain(:items, :find_by).and_return(item)
      allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
      allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(page)
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
    end

    context 'updating item property' do
      before do
        params[:item][:name] = 'new name'
        allow(item_page).to receive(:link_to?).and_return(false)
        put :update_item, params: params, xhr: true
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'updating item link to page' do
      let(:link_to_page) { double('page', name: 'page name') }

      before do
        page_name = 'name of page to link'
        params[:link_to_page] = page_name
        allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .with(id: page_name).and_return(link_to_page)
        allow(item_page).to receive(:update)
        allow(item_page).to receive(:link_to?).and_return(false)
        put :update_item, params: params, xhr: true
      end

      it 'updates link to page' do
        expect(item_page).to have_received(:update)
          .with(link_to: link_to_page.name)
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'removin item link to page' do

      before do
        allow(item_page).to receive(:update)
        allow(item_page).to receive(:link_to?).and_return(true)
        put :update_item, params: params, xhr: true
      end

      it 'sets link to page to nil' do
        expect(item_page).to have_received(:update).with(link_to: nil)
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'DELETE #remove_item' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:params) {
      {
        id: page,
        spreadsheet_id: spreadsheet,
        user_id: user
      }
    }

    before do
      allow(spreadsheet).to receive_message_chain(:pages, :first)
          .and_return(page)
      allow(spreadsheet).to receive_message_chain(:pages, :find_by)
          .and_return(page)
      allow(user).to receive_message_chain(:spreadsheets, :first)
        .and_return(spreadsheet)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
    end

    context "when page doesn't has the item" do
      let(:item) { create(:item) }

      before do
        params[:item_id] = item.id
        delete :remove_item, params: params, xhr: true
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when page has the item' do
      context 'private item' do
        let(:item) { create(:item, image: create(:private_image)) }
        let(:item_page_id) { 1 }

        before do
          page.items << item
          params.merge!({
            item_id: item.id,
            item_page_id: item_page_id
          })
          allow(page).to receive_message_chain(:item_pages, :destroy)
            .with(item_page_id.to_s).and_return(true)
          delete :remove_item, params: params, xhr: true
        end


        it 'responds with success status' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'item from a pictogram' do
        let(:item) { create(:item, image: create(:pictogram)) }

        before do
          page.items << item
          params[:item_id] = item.id
          allow(Item).to receive(:destroy).with(item.id).and_return(true)
          delete :remove_item, params: params, xhr: true
        end


        it 'responds with success status' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe 'PUT #swap_items' do
    let(:spreadsheet) { user.spreadsheets.first }
    let(:page) { spreadsheet.pages.first }
    let(:item_1) { create(:item) }
    let(:item_2) { create(:item) }
    let(:params) {
      {
        id: page,
        spreadsheet_id: spreadsheet,
        user_id: user,
        id_1: item_1.id,
        id_2: item_2.id
      }
    }

    before do
      page.items << item_2 << item_1
      allow(page).to receive(:swap_items)
      allow(spreadsheet).to receive_message_chain(:pages, :first)
        .and_return(page)
      allow(spreadsheet).to receive_message_chain(:pages, :find_by)
        .and_return(page)
      allow(user).to receive_message_chain(:spreadsheets, :find_by)
        .and_return(spreadsheet)
      put :swap_items, params: params, xhr: true
    end

    it 'responds with success status' do
      expect(page).to have_received(:swap_items)
        .with(item_1.id.to_s, item_2.id.to_s)
    end

    it 'responds with success status' do
      expect(response).to have_http_status(:success)
    end
  end
end
