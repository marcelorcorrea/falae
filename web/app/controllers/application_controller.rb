class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper
  include SessionsHelper

  def authenticate!
    unless logged_in?
      redirect_to root_path
    end
  end

  # Ensure correct user
  def correct_user
    #NOTE: is it necessary to hit database (use id directly) ?
    redirect_to root_path unless current_user?(User.find(params[:user_id] || params[:id]))
  end
end
