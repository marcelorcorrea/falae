class HomeController < ApplicationController
  before_action :session_expired?

  def home
  end

  def about
  end

  def contact
  end
end
