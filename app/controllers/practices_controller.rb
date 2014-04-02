class PracticesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @practices = Practice.page params[:page]
  end

  def check
    @practice = Practice.find params[:id]
    @user = User.find params[:user_id]
  end

  def show
    @practice = Practice.find params[:id]
  end
end