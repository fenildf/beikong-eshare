class Charts::CoursesController < ApplicationController
  before_filter :authenticate_user!
  
  def all_courses_read_pie
    render :json => current_user.course_read_stat
  end

  def all_courses_punch_card
    @stat = current_user.course_weekdays_stat
    render :layout => false
  end

  def read_pie
    @course = Course.find params[:id]
    render :json => @course.course_wares_read_stat_of(current_user)
  end

  def all_courses_select_apply_pie
    @courses = SelectCourseIntent.intent_course_ranking

    stat = {
      :notfull => 0, :full => 0, :over => 0, :empty => 0
    }

    result = @courses.each do |course|
      min = course.least_user_count
      max = course.most_user_count
      count = course.intent_student_count

      if count == 0
        stat[:empty] = stat[:empty] + 1
        next
      end

      if min && count < min
        stat[:notfull] = stat[:notfull] + 1 
        next
      end

      if max && count > max
        stat[:over] = stat[:over] + 1 
        next
      end

      stat[:full] = stat[:full] + 1 
    end

    render :json => stat
  end
end