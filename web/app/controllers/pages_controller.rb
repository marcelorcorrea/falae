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
    @page.destroy
    respond_to do |format|
      format.html { redirect_to user_spreadsheets_url, notice: t('.notice') }
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
    render locals: { items: items }
  end

  # POST
  def add_to_page
    if item_params[:id]
      item = Item.find_by id: item_params[:id]
      @page.items << item if item
    else
      @page.items.create item_params
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
    ip = ItemPage.find_by page_id: @page.id, item_id: params[:item_id]

    if params[:page_id].present?
      page = @spreadsheet.pages.find_by id: params[:page_id]
      ip.link_to = page.name
    else
      ip.link_to = nil
    end
    # TODO error message when there no such objects
    ip.save
  end

  # DELETE
  def remove_item
    item = @page.items.find_by id: params[:item_id]
    @page.items.delete item if item
  end

  # PUT
  def swap_items
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
