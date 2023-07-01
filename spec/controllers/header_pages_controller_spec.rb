require 'rails_helper'

RSpec.describe HeaderPagesController, type: :controller do
  before do
    allow(controller).to receive(:set_locale)
  end

  describe 'GET #home' do
    before do
      get :home
    end

    it 'renders the home template' do
      expect(response).to render_template('home')
    end

    it 'should respond with success' do
      expect(response).to be_successful
    end
  end

  describe 'GET #about' do
    before do
      get :about
    end

    it 'renders the about template' do
      expect(response).to render_template('about')
    end

    it 'should respond with success' do
      expect(response).to be_successful
    end
  end

  describe 'GET #contact' do
    before do
      get :contact
    end

    it 'renders the contact template' do
      expect(response).to render_template('contact')
    end

    it 'should respond with success' do
      expect(response).to be_successful
    end
  end
end
