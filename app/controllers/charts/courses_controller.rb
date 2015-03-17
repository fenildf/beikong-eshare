class Charts::CoursesController < ApplicationController
  before_filter :authenticate_user!
  
  def all_courses_read_pie
    render :json => current_user.course_read_stat
  end

  def read_pie
    @course = Course.find params[:id]
    render :json => @course.course_wares_read_stat_of(current_user)
  end

end