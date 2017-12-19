class ItemsController < ApplicationController
  before_action :authenticate!
  before_action :authorized?
  before_action :set_vars
  before_action :set_item, only: [:show, :edit, :update, :destroy, :image]

  # GET /items
  # GET /items.json
  def index
    @items = @user.items
  end

  # GET /items/1
  # GET /items/1.json
  def show
  end

  # GET /items/new
  def new
    @item = @user.items.new
    @item.image = Image.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = @user.items.build item_params

    respond_to do |format|
      if @item.save
        format.html { redirect_to user_items_url(@user), notice: t('.notice') }
        format.json { render :show, status: :created, location: @item }
      else
        @item.image = Image.new
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

  # GET image
  def image
    img = @item.image
    send_file img.image.path, filename: SecureRandom.hex[0..7],
      type: img.image_content_type, disposition: :inline
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = @user.items.find_by id: params[:id]
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
    attrs = params.require(:item).permit(:name, :speech, :category_id,
                                         image_attributes: [:image, :id])
    attrs[:image_attributes][:user_id] = current_user.id
    attrs
  end
end
