class IndexController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :bk_login]
  layout 'dashboard', :only => [:dashboard]

  def index
    if !user_signed_in?
      return redirect_to '/account/sign_in'
    end

    return redirect_to "/admin_home" if current_user.is_admin?
    return redirect_to "/teacher_home" if current_user.is_teacher?
    return redirect_to "/manager_home" if current_user.is_manager?
    return redirect_to "/student_home" if current_user.is_student?
  end

  def admin_home
    # nothing
  end

  def teacher_home
  end

  def student_home
  end

  def manager_home
  end

  def dashboard
    # 教师和学生的工作台页面
  end

  def plan
    # 学习计划和教学计划页面
  end

  def bk_login
    # 北控单点登录
    render :layout => 'auth'
  end

  def download_attach
    file_entity = FileEntity.find params[:file_entity_id]
    send_file file_entity.attach.path, :filename => file_entity.attach_file_name
  end
end
