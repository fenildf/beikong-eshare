class IndexController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  layout 'dashboard', :only => [:dashboard]

  def index
    if !user_signed_in?
      return redirect_to '/account/sign_in'
    end

    return redirect_to "/admin" if current_user.is_admin?
    return redirect_to "/teacher_home" if current_user.is_teacher?
    return redirect_to "/manage/courses" if current_user.is_manager?
    return redirect_to "/select_course_intents" if current_user.is_student?
  end

  def teacher_home
  end

  def dashboard
    # 教师和学生的工作台页面
  end

  def plan
    # 学习计划和教学计划页面
  end
end
