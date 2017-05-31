class ItemsController < ApplicationController
  before_action :authenticate!
  before_action :authorized?
  before_action :set_vars
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    # @items = Item.all
    @items = if params[:search]
      Item.defaults.where('name LIKE ?', "%#{item_params[:name]}%")
    else
      @user.items
    end

    #respond_to do |format|
    #  format.html
    #  format.json
    #  format.js
    #end

    #@item = @user.items.build
  end

  # GET /items/1
  # GET /items/1.json
  def show
  end

  # GET /items/new
  def new
    #@item = Item.new
    @item = @user.items.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    #@item = Item.new(item_params)
    @item = @user.items.build item_params
    @item.category = Category.find_by(id: params[:category_id])

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      #@item = Item.find(params[:id])
      @item = @user.items.find_by id: params[:id]
    end

    def set_vars
      @user = current_user
      #if params[:spreadsheet_id] and params[:page_id]
        #@spreadsheet = @user.spreadsheets.find_by id: params[:spreadsheet_id]
        #@page = @spreadsheet.pages.find_by id: params[:page_id]
      #end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:name, :img_src, :speech)
    end
end
