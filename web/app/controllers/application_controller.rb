class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper
  include SessionsHelper

  def authenticate!
    puts "authenticate! #{logged_in?}"
    unless logged_in?
      redirect_to root_path
    end
  end

  # Ensure authorized user
  def authorized?
    #NOTE: is it necessary to hit database (use id directly) ?
    id = params[:user_id] || params[:id]
    puts "authorized? #{current_user?(User.find_by(id: id))}"
    redirect_to root_path unless current_user?(User.find_by(id: id))
  end
end
