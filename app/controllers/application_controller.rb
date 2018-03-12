class ApplicationController < ActionController::Base
  before_action :set_locale
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  include ApplicationHelper
  include SessionsHelper

  def authenticate!
    if !logged_in? && !user_from_token_authentication
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { unauthorized_json_access }
      end
    end
  end

  # Ensure authorized user
  def authorized?
    id = params[:user_id] || params[:id]
    unless current_user?(User.find_by(id: id))
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { unauthorized_json_access }
      end
    end
  end

  protected
    def unauthorized_json_access
      response['WWW-Authenticate'] = 'Body realm="Access for Android app"'
      render json: {error: 'Access Denied'}, status: :unauthorized
    end

  private
    def set_locale
      I18n.locale = http_accept_language.compatible_language_from(
        I18n.available_locales) || I18n.default_locale
    end
end
