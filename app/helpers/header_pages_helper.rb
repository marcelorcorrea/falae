module HeaderPagesHelper
  def home
    if current_user
      user_spreadsheets_path current_user
    else
      home_path
    end
  end

  def home_page?
    current_page? home
  end

  def about_page?
    current_page? about_path
  end

  def contact_page?
    current_page? contact_path
  end

  def header_pages?
    home_page? || about_page? || contact_page?
  end
end
