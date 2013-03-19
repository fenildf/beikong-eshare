class CoursesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :pre_load

  def pre_load
    @course = Course.find(params[:id]) if params[:id]
  end

  def index
    @courses = Course.page params[:page]
  end

  def new
    @course = Course.new
  end

  def create
    @course = current_user.courses.build(params[:course])
    if @course.save
      return redirect_to :action => :index
    end
    render :action => :new
  end

  def show
  end

  def edit
  end

  def update
    if @course.update_attributes(params[:course])
      return redirect_to :action => :index
    end
    render :action => :edit
  end

  def destroy
    @course.destroy
    redirect_to :action => :index
  end
end