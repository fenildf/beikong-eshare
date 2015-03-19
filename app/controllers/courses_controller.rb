class CoursesController < ApplicationController
  before_filter :authenticate_user!, 
                :except => [:show, :questions, :users_rank]
  before_filter :pre_load
  
  layout Proc.new { |controller|
    case controller.action_name
    when 'index'
      return 'course_center'
    when 'show', 'users_rank', 'questions', 'notes', 'chs'
      return 'course_show'
    else
      return 'application'
    end
  }

  def pre_load
    @course = Course.find(params[:id]) if params[:id]
  end

  def mine
    @courses = current_user.selected_courses.page(params[:page]).per(18)
  end

  def favs
    @courses = current_user.fav_courses.page(params[:page]).per(18)
  end

  def index
    @groups = []

    GroupTreeNode.roots.with_teacher.each do |g|
      _r_group @groups, g
    end
  end

  def _r_group(groups, group)
    groups << group
    group.children.each do |g|
      _r_group groups, g
    end
  end

  def sch_select
    @courses = Course.page(params[:page]).per(18)
  end

  def show
    if params[:index].blank?
      return redirect_to :action => :chs
    end
  end

  def manage
    @courses = current_user.courses.page(params[:page])
  end

  def manage_one
  end

  # 签到
  def checkin
    @course.sign current_user
    render :json => {
      :streak => @course.current_streak_for(current_user),
      :order => @course.today_sign_order_of(current_user)
    }
  end

  # 用户排名
  def users_rank
    @rank = @course.users_rank
  end

  # 学生选课 INHOUSE
  def student_select
    if params[:cancel]
      current_user.cancel_select_course @course
      
      case params[:page]
      when 'sch_select'
        render :json => { 
          :status => 'request',
          :html => ( render_cell :course, :sch_select_table, 
                                 :user => current_user, 
                                 :courses => [@course] )
        }
      else
        render :json => { :status => 'cancel' }
      end

      return
    end

    current_user.select_course @course

    case params[:page]
    when 'sch_select'
      render :json => { 
        :status => 'request',
        :html => ( render_cell :course, :sch_select_table, 
                               :user => current_user, 
                               :courses => [@course] )
      }
    else
      render :json => { :status => 'request' }
    end
  end

  def questions
    @questions = @course.questions.page params[:page]
  end

  def notes
    @notes = @course.notes.page params[:page]
  end

  def chs
    @announcements = @course.announcements
  end

  def dofav
    @course.set_fav current_user
    redirect_to @course
  end

  def unfav
    @course.cancel_fav current_user
    redirect_to @course
  end

  def join
    current_user.select_course SelectCourse::STATUS_ACCEPT, @course
    redirect_to @course
  end

  def exit
    current_user.cancel_select_course @course
    redirect_to @course
  end

  # 20150128 添加
  # 方便老师从课程中移除学生
  def unselect
    user = User.find params[:user_id]
    user.cancel_select_course @course
    redirect_to "/courses/#{@course.id}/users_rank"
  end
end