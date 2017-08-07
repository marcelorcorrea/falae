class ItemsController < ApplicationController
  before_action :authenticate!
  before_action :authorized?
  before_action :set_vars
  before_action :set_item, only: [:show, :edit, :update, :destroy, :image]

  # GET /items
  # GET /items.json
  def index
    # @items = Item.all
    @items = if params[:search]
      if item_params[:name].blank?
        []
      else
       Item.defaults.where('name LIKE ?', "#{item_params[:name]}%")
      end
    else
      @user.items
    end
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
        format.html { redirect_to action: :index, notice: t('.notice') }
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
        format.html { redirect_to [@item.user, @item], notice: t('.notice') }
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
      format.html { redirect_to user_items_url(@user), notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  def add_to_user
    @item = Item.defaults.find_by id: params[:id]
    if @item and not @item.has?(@user)
      @user.items << @item
    end
  end

  # TODO: obsolete?
  def add_to_page
    @item = Item.defaults.find_by id: params[:id]
    if @item and not @item.in_page?(@page)
      @page.items << @item
      @user.items << @item unless @item.has?(@user)
      @item.reload
    end
  end

  # GET image
  def image
    send_file @item.image.path, type: @item.image_content_type
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @user.items.find_by id: (params[:id] || params[:item_id])
    end

    def set_vars
      @user = current_user
      if params[:spreadsheet_id] and params[:page_id]
        @spreadsheet = @user.spreadsheets.find_by id: params[:spreadsheet_id]
        @page = @spreadsheet.pages.find_by id: params[:page_id]
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:name, :speech, :image)
    end
end
