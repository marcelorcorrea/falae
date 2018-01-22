module HomeHelper
  def home
    if current_user
      user_spreadsheets_path current_user
    else
      home_path
    end
  end
end
