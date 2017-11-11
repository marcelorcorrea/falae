module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    reset_session
    renew_session
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_user?(user)
    current_user == user
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
