class Manage::SelectCourseIntentsController < ApplicationController
  before_filter :authenticate_user!
  layout Proc.new { |controller|
    case controller.action_name
    when 'index', 'list'
      return 'grid'
    else
      return 'application'
    end
  }

  def index
    @courses = SelectCourseIntent.intent_course_ranking
  end

  def list
    @course = Course.find params[:course]
    @students = @course.intent_student_users
  end
end