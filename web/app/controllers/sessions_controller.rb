class SessionsController < ApplicationController
  def new
  end

  def register
    @user = User.new
  end
end
