require 'will_paginate/array'

class PagesController < ApplicationController
  before_action :authenticate!
  before_action :authorized?
  before_action :set_vars
  # before_action :set_page, only: [:show, :edit, :update, :destroy, :add_item, :search_item, :add_to_page]
  before_action :set_page, except: [:index, :new, :create]

  # GET /pages
  # GET /pages.json
  def index
    @pages = @spreadsheet.pages
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    respond_to do |format|
      if @spreadsheet && @page
        format.html { render :show }
        format.json { render :show, location: @page }
      elsif !@spreadsheet
        format.html { redirect_to user_spreadsheets_url }
        format.json { render 'spreadsheets/index' }
      else
        format.html { redirect_to [@spreadsheet.user, @spreadsheet] }
        format.json { render :show, location: @spreadsheet }
      end
    end
  end

  # GET /pages/new
  def new
    #@page = Page.new
    @page = @spreadsheet.pages.new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = @spreadsheet.pages.build page_params

    respond_to do |format|
      if @page.save
        format.html { redirect_to [@spreadsheet.user, @spreadsheet, @page], notice: t('.notice') }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to [@page.spreadsheet.user, @page.spreadsheet, @page], notice: t('.notice') }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @spreadsheet.pages.destroy @page
    @page.destroy
    respond_to do |format|
      format.html { redirect_to user_spreadsheet_url(@user, @spreadsheet), notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  # TODO: Notify on error
  # GET
  def add_item
  end

  # TODO review it!
  # GET
  def search_item
    items = if params[:search] && params[:name].present?
      name = params[:name]
      private_items = @user.find_items_like_by name: name
      pictograms = Pictogram.find_like_by image_file_name: name
      private_items + pictograms.map(&:generate_item)
    else
      []
    end
    items_paginated = items.paginate page: params[:offset], per_page: 5
    render locals: { items: items_paginated }
  end

  # POST
  def add_to_page
    if item_params[:id]
      item = Item.find_by id: item_params[:id]
      @page.items << item if item
    else
      params = item_params.merge user_id: current_user.id
      @page.items.create params
    end
    @page.reload
  end

  # GET
  def edit_item
    item = @page.items.find_by id: params[:item_id]
    render locals: { item: item }
  end

  # PUT
  def update_item
    return if item_params[:id].blank?

    item = @page.items.find_by id: item_params[:id]
    return unless item

    item.assign_attributes item_params
    item.save
    item_page = ItemPage.find_by page_id: @page.id, item_id: item.id
    return unless item_page

    if params[:link_to_page].present?
      link_to_page = @spreadsheet.pages.find_by id: params[:link_to_page]
      if link_to_page
        item_page.link_to = link_to_page.name
        item_page.save
      end
    elsif item_page.link_to.present?
      item_page.link_to = nil
      item_page.save
    end
  end

  # DELETE
  def remove_item
    item = @page.items.find_by id: params[:item_id]
    if item.private?
      @page.items.destroy item
    else
      Item.destroy item.id
    end
  end

  # PUT
  def swap_items
    # TODO check if @page has items with id_1 and id_2
    @page.swap_items params[:id_1], params[:id_2]
  end
  # END TODO: Notify on error

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = @spreadsheet ? @spreadsheet.pages.find_by(id: params[:id]) : nil
  end

  def set_vars
    @user = current_user
    @spreadsheet = @user.spreadsheets.find_by id: params[:spreadsheet_id]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def page_params
    params.require(:page).permit(:name, :columns, :rows, :spreadsheet_id)
  end

  def item_params
    params.require(:item).permit(:id, :name, :speech, :category_id,
                                 image_attributes: [:image, :id])
  end
end
