class AnnouncementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :pre_load

  def pre_load
    @announcement = Announcement.find(params[:id]) if params[:id]
  end

  def index
    @announcements = Announcement.page params[:page]
  end

  def show
    @announcement.read_by_user(current_user)
  end


end