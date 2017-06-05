module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    reset_session
    session[:expires_after] = 1.hour.from_now.to_i
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
    current_user.present? && check_session_validity
  end

  def log_out
    reset_session
    @current_user = nil
  end

  def check_session_validity
    if session[:expires_after] && session[:expires_after] > Time.now.to_i
      return true
    end
    false
  end
end
