class SpreadsheetsController < ApplicationController
  before_action :authenticate!
  before_action :authorized?, only: [ :show, :edit, :update]
  before_action :set_spreadsheet, only: [:show, :edit, :update, :destroy]

  # GET /spreadsheets
  # GET /spreadsheets.json
  def index
    #@spreadsheets = Spreadsheet.all
    @user = current_user
    @spreadsheets = @user.spreadsheets
  end

  # GET /spreadsheets/1
  # GET /spreadsheets/1.json
  def show
    @user = current_user
    @pages = @spreadsheet.pages
  end

  # GET /spreadsheets/new
  def new
    @spreadsheet = Spreadsheet.new
  end

  # GET /spreadsheets/1/edit
  def edit
  end

  # POST /spreadsheets
  # POST /spreadsheets.json
  def create
    @spreadsheet = current_user.spreadsheets.build spreadsheet_params

    respond_to do |format|
      if @spreadsheet.save
        format.html { redirect_to [user, @spreadsheet], notice: 'Spreadsheet was successfully created.' }
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
        format.html { redirect_to [@spreadsheet.user, @spreadsheet], notice: 'Spreadsheet was successfully updated.' }
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
    @spreadsheet.destroy
    respond_to do |format|
      format.html { redirect_to spreadsheets_url, notice: 'Spreadsheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_spreadsheet
      @spreadsheet = Spreadsheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def spreadsheet_params
      params.require(:spreadsheet).permit(:name, :initial_page)
    end
end
