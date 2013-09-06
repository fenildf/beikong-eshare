class AnnouncementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :pre_load

  layout 'grid'

  before_filter :set_subsystem
  def set_subsystem
    @subsystem = :xuanke
  end  

  def pre_load
    @announcement = Announcement.find(params[:id]) if params[:id]
  end

  def index
    if current_user.is_teacher?
      @announcements = Announcement.with_role_teacher.page params[:page]
    elsif current_user.is_student?
      @announcements = Announcement.with_role_student.page params[:page]
    end
  end

  def show
    @announcement.read_by_user(current_user)
  end


end