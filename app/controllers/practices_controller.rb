class PracticesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @practices = Practice.page params[:page]
  end
end