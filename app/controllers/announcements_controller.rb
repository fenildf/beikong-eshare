class AnnouncementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :pre_load

  before_filter :set_subsystem
  def set_subsystem
    @subsystem = :xuanke
  end  

  def pre_load
    @announcement = Announcement.find(params[:id]) if params[:id]
  end

  def index
    @announcements = current_user.announcements.page params[:page]
  end

  def show
  end


end