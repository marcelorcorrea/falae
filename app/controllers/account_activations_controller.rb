class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authentic_token?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = t('user_mailer.account_activation.activation')
      redirect_to user_spreadsheets_path(user)
    else
      flash[:alert] = t('user_mailer.account_activation.invalid')
      redirect_to root_url
    end
  end
end
