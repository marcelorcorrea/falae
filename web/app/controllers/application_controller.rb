class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  include ApplicationHelper
  include SessionsHelper

  def authenticate!
    unless logged_in?
      redirect_to root_path
    end
  end

  # Ensure authorized user
  def authorized?
    id = params[:user_id] || params[:id]
    redirect_to root_path unless current_user?(User.find_by(id: id))
  end
end
