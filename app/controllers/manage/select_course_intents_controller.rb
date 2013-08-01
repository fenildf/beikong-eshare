class Manage::SelectCourseIntentsController < ApplicationController
  before_filter :authenticate_user!
  layout Proc.new { |controller|
    case controller.action_name
    when 'index', 'list', 'adjust'
      return 'grid'
    else
      return 'application'
    end
  }

  def index
    @courses = SelectCourseIntent.intent_course_ranking

    if current_user.is_teacher?
      @courses = @courses.select {|c|
        c.creator == current_user
      }
    end
  end

  def list
    @course = Course.find params[:course]
    @students = @course.intent_student_users
  end

  def adjust
    @course = Course.find params[:course]
    @students = SelectCourse.no_selected_course_users.page(params[:page]).per(15)
  end

  def accept
    @user = User.find params[:user_id]
    @course = Course.find params[:course_id]

    @user.select_course(:accept, @course)

    render :json => { 
      :status => 'ok',
      :html => ( render_cell :course_select, :manage_table, 
                             :users => [@user],
                             :course => @course)
    }
  end

  def reject
    @user = User.find params[:user_id]
    @course = Course.find params[:course_id]

    @user.select_course(:reject, @course)

    render :json => { 
      :status => 'ok',
      :html => ( render_cell :course_select, :manage_table, 
                             :users => [@user],
                             :course => @course)
    }
  end

end