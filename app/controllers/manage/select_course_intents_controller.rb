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

  before_filter :set_subsystem
  def set_subsystem
    @subsystem = :xuanke
  end  

  def index
    @courses = CourseIntent.intent_course_ranking

    if current_user.is_teacher?
      @courses = @courses.select {|c|
        c.creator == current_user
      }
    end
  end

  def list
    @course = Course.find params[:course]
    @students = @course.intent_and_selected_users.page(params[:page]).per(15)
  end

  def adjust
    @course = Course.find params[:course]
    @students = @course.need_adjust_users.page(params[:page]).per(15)
  end

  def accept
    @user = User.find params[:user_id]
    @course = Course.find params[:course_id]

    @user.select_course(:accept, @course)

    render :json => { 
      :status => 'ok',
      :accept_count => @course.selected_users.count,
      :reject_count => @course.be_reject_selected_users.count,
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
      :accept_count => @course.selected_users.count,
      :reject_count => @course.be_reject_selected_users.count,
      :html => ( render_cell :course_select, :manage_table, 
                             :users => [@user],
                             :course => @course)
    }
  end

  # 批量处理三个志愿
  def batch_check
    course = Course.find params[:course]
    flag = params[:flag].to_sym
    course.batch_check flag

    redirect_to "/manage/select_course_intents/list?course=#{params[:course]}"
  end

  # 批量处理单一志愿
  def batch_check_one
    course = Course.find params[:course]
    course.batch_check

    redirect_to "/manage/select_course_intents/list?course=#{params[:course]}"
  end

end