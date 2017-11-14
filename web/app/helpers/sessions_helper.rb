module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    if request.format.json?
      user.revalidate_token_access
    else
      reset_session
      renew_session
      session[:user_id] = user.id
    end
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
    @current_user ||= get_user
  end

  def current_user?(user)
    current_user == user
  end

  def get_user
    user_from_session || user_from_token_authentication
  end

  def user_from_token_authentication
    authenticate_with_http_token do |token, _|
      if user = User.with_unexpired_auth_token(token, 1.hour.ago)
        # Compare the tokens in a time-constant manner, to mitigate timing attacks.
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(token),
          ::Digest::SHA256.hexdigest(user.auth_token)
        ) && user
      end
    end
  end

  def user_from_session
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present? && session_valid?
  end

  def log_out
    reset_session
    @current_user = nil
  end

  def renew_session
    session[:expires_after] = 30.minute.from_now.to_i
  end

  def session_valid?
    !session_expired? && !!renew_session
  end

  def session_expired?
    session[:expires_after] && session[:expires_after] < Time.now.to_i
  end

end
