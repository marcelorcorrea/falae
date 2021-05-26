class SpreadsheetsController < ApplicationController
  before_action :authenticate!
  before_action :authorized?
  before_action :set_vars
  before_action :set_spreadsheet,
    only: %i[
      show
      edit
      update
      destroy
      import_spreadsheet
      add_page
      export
      export_data
    ]

  # GET /spreadsheets
  # GET /spreadsheets.json
  def index
    @spreadsheets = @user.spreadsheets
  end

  # GET /spreadsheets/1
  # GET /spreadsheets/1.json
  def show
    respond_to do |format|
      if @spreadsheet
        @pages = @spreadsheet.pages
        format.html { render :show }
        format.json { render :show, location: @spreadsheet }
      else
        format.html { redirect_to user_spreadsheets_url }
        format.json { render :index }
      end
    end
  end

  # GET /spreadsheets/new
  def new
    @spreadsheet = @user.spreadsheets.new
  end

  # GET /spreadsheets/1/edit
  def edit
  end

  # POST /spreadsheets
  # POST /spreadsheets.json
  def create
    @spreadsheet = @user.spreadsheets.build spreadsheet_params

    respond_to do |format|
      if @spreadsheet.save
        format.html { redirect_to [@user, @spreadsheet], notice: t('.notice') }
        format.json { render :show, status: :created, location: @spreadsheet }
      else
        format.html { render :new }
        format.json { render json: @spreadsheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /spreadsheets/1
  # PATCH/PUT /spreadsheets/1.json
  def update
    respond_to do |format|
      if @spreadsheet.update(spreadsheet_params)
        format.html { redirect_to [@user, @spreadsheet], notice: t('.notice') }
        format.json { render :show, status: :ok, location: @spreadsheet }
      else
        format.html { render :edit }
        format.json { render json: @spreadsheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spreadsheets/1
  # DELETE /spreadsheets/1.json
  def destroy
    @user.spreadsheets.destroy @spreadsheet
    respond_to do |format|
      format.html { redirect_to user_spreadsheets_url, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  # GET /spreadsheets/1/import_page
  def import_page
    render locals: { spreadsheet: @spreadsheet }
  end

  # POST /spreadsheets/1/add_page
  def add_page
    if params[:page_file].blank?
      render :update_pages_list,
        locals: { error: t('.no_file') },
        status: :bad_request
      return
    end

    page_encrypted = params[:page_file].read
    error = Page.import page_encrypted, @spreadsheet, @user
    if !error
      @pages = @spreadsheet.pages
      render :update_pages_list, locals: { initial_page: (@pages.one? && @pages.first.name) }
    else
      render :update_pages_list,
        locals: { error: error },
        status: :unprocessable_entity
    end
  end

  # GET
  def export
    render locals: { filename: "#{@spreadsheet.name}.#{t('.ext')}" }
  end

  # GET
  def export_data
    send_data @spreadsheet.export(params[:include_private_items]),
      disposition: :attachment,
      filename: "#{@spreadsheet.name}.#{t('.ext')}",
      type: 'application/octetstream'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_spreadsheet
    @spreadsheet = @user.spreadsheets.find_by id: (params[:id] || params[:spreadsheet_id])
  end

  def set_vars
    @user = current_user
  end

  def spreadsheet_params
    params.require(:spreadsheet).permit(:name, :initial_page)
  end
end
