module HomeHelper
  def home
    if current_user
      if request.path.start_with? user_path(current_user)
        request.path
      else
        user_spreadsheets_path current_user
      end
    else
      home_path
    end
  end
end
