module LayoutHelper
  def show_nav_menu?
    logged_in? && (home_page? || !header_pages?)
  end
end
