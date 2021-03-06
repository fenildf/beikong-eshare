class Manage::AnnouncementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :pre_load

  def pre_load
    @announcement = Announcement.find(params[:id]) if params[:id]
  end


  def index
    @announcements = Announcement.page params[:page]
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = current_user.announcements.build(params[:announcement])
    if @announcement.save
      flash[:success] = '公告创建成功'
      return redirect_to :action => :index
    end
    render :action => :new
  end

  def update
    if @announcement.update_attributes(params[:announcement])
      flash[:success] = '公告修改成功'
      return redirect_to :action => :index
    end
    render :action => :edit
  end

  def destroy
    @announcement.destroy
    redirect_to :action => :index
  end

end