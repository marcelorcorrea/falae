class UsersController < ApplicationController
  before_action :authenticate!, except: %i[new create]
  before_action :authorized?, except: %i[new create]
  before_action :set_user, except: %i[new create]

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(create_params)

    respond_to do |format|
      if @user.save
        flash[:warning] = t('user_mailer.account_activation.verification')
        format.html { redirect_to root_url }
        format.json { render :show, status: :created, location: @user }
      else
        @user.photo = nil
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(update_params)
        I18n.locale = @user.locale
        format.html { redirect_to @user, notice: t('.notice') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET users/1/photo
  def photo
    send_file(@user.photo.path, filename: SecureRandom.hex[0..7],
      type: @user.photo_content_type, disposition: :inline)
  end

  # GET users/1/change_email
  def change_email
  end

  # GET users/1/change_password
  def change_password
  end

  # PATCH users/1/update_email
  def update_email
    respond_to do |format|
      if !@user.authenticate!(params[:user][:password], :password)
        error_msg = t('.incorrect_password')
        flash.now[:alert] = error_msg
        format.html { render :change_email }
        format.json { render json: { error: error_msg }, status: :unprocessable_entity }
      elsif @user.update(email_update_params)
        format.html { redirect_to @user, notice: t('.notice') }
        format.json { render :show, status: :ok, location: @user }
      else
        error_msg = t('.invalid_email')
        flash.now[:alert] = error_msg
        format.html { render :change_email }
        format.json { render json: {error: error_msg}, status: :unprocessable_entity }
      end
    end
  end

  # PATCH users/1/update_password
  def update_password
    respond_to do |format|
      if !@user.authenticate!(params[:user][:current_password], :current_password)
        error_msg = t('.incorrect_password')
        flash.now[:alert] = error_msg
        format.html { render :change_password }
        format.json { render json: { error: error_msg }, status: :unprocessable_entity }
      elsif @user.update_password_with_context(password_update_params)
        format.html { redirect_to @user, notice: t('.notice') }
        format.json { render :show, status: :ok, location: @user }
      else
        error_msg = t('.invalid_password')
        flash.now[:alert] = error_msg
        format.html { render :change_password }
        format.json { render json: { error: error_msg }, status: :unprocessable_entity }
      end
    end
  end


  # GET /users/1/import_spreadsheet
  def import_spreadsheet
    render locals: { user: @user }
  end

  # POST /users/1/add_spreadsheet
  def add_spreadsheet
    file = params[:user][:spreadsheet_file]
    if params[:user][:spreadsheet_file].blank?
      render :update_spreadsheet_list,
        locals: { error: t('.no_file') },
        status: :bad_request
      return
    end

    spreadsheet_encrypted = file.read
    error = Spreadsheet.import spreadsheet_encrypted, @user
    if !error
      @spreadsheets = @user.spreadsheets
      render :update_spreadsheet_list
    else
      render :update_spreadsheet_list,
        locals: { error: error },
        status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user
  end

  def create_params
    params.require(:user)
      .permit(:name, :last_name, :profile, :email, :email_confirmation,
        :password, :password_confirmation, :photo, :locale, :crop_x, :crop_y,
        :crop_w, :crop_h)
  end

  def update_params
    params.require(:user)
      .permit(:name, :last_name, :profile, :photo, :locale, :crop_x, :crop_y,
        :crop_w, :crop_h)
  end

  def email_update_params
    params.require(:user).except(:password)
      .permit(:email, :email_confirmation)
  end

  def password_update_params
    params.require(:user).except(:current_password)
      .permit(:password, :password_confirmation)
  end
end
