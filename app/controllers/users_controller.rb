class UsersController < ApplicationController
  before_action :authenticate!, only: [:index, :show, :edit, :update, :photo]
  before_action :authorized?, only: [:index, :show, :edit, :update, :photo]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :photo]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
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
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html {
          flash[:warning] = t('user_mailer.account_activation.verification')
          redirect_to root_url
        }
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
    skip_password_if_not_changed
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('.notice') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # def destroy
  #   @user.destroy
  #   respond_to do |format|
  #     format.html { redirect_to users_url, notice: t('.notice') }
  #     format.json { head :no_content }
  #   end
  # end

  # GET users/1/photo
  def photo
    send_file @user.photo.path, filename: SecureRandom.hex[0..7],
      type: @user.photo_content_type, disposition: :inline
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      #@user = User.find(params[:id])
      @user = current_user
    end

    def user_params
      params.require(:user).permit(:name, :last_name, :email, :password,
        :password_confirmation, :profile, :photo, :crop_x, :crop_y, :crop_w,
        :crop_h)
    end

    def skip_password_if_not_changed
      if user_params[:password].blank? && user_params[:password_confirmation].blank?
        user_params.delete :password
        user_params.delete :password_confirmation
      end
    end
end
