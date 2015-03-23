SimpleNavbar::Base.config do
  rule :admin do
    nav :index, :url => '/admin_home' do
      controller :index, :only => [:admin_home]
    end

    nav :users_manage, :url => '/admin/users' do
      controller :'admin/users'
    end

    nav :users_group, :url => '/admin/user_groups' do
      controller :'admin/user_groups'
    end 

    nav :categories_manage, :url => '/admin/categories' do
      controller :'admin/categories'
    end

    nav :course_center, :url => '/courses' do
      controller :courses, :only => :index
    end

    nav :auth_bg, :url => '/admin/auth_image_setting' do
      controller :'admin/config'
    end
  end

  # 教学领导
  rule :manager do
    # 领导首页
    nav :index, :url => '/manager_home' do
      controller :index, :only => [:manager_home]
    end

    nav :announcements, :url => '/manage/announcements' do
      controller :'manage/announcements'
      controller :announcements
    end

    nav :course_center, :url => '/courses' do
      controller :courses, :only => :index
    end
  end

  # -------------------------------------

  # 教师
  rule :teacher do
    # 教师首页
    nav :index, :url => '/teacher_home' do
      controller :index, :only => :teacher_home
    end

    # 公共动态
    nav :dashboard, :url => '/dashboard' do
      controller :index, :only => :dashboard
    end

    # 发布公告
    nav :announcements, :url => '/manage/announcements' do
      controller :'manage/announcements'
      controller :announcements
    end
  end

  # 教师课程模块
  rule :teacher_course do
    nav :course_center, :url => '/courses' do
      controller :courses, :only => :index
    end

    # 课程编排
    nav :course_design, :url => '/manage/courses' do
      controller :'manage/courses'
      controller :'manage/chapters'
    end

    # 文件共享
    nav :file_upload, :url => '/disk' do
      controller :disk
    end
  end

  # 教师作业与问答模块
  rule :teacher_homework do
    # 检查作业
    nav :check_practice, :url => '/manage/practices' do
      controller :'manage/practices'
    end

    # 问答
    nav :questions, :url => '/questions' do
      controller :questions
    end
  end

  # --------------

  # 学生
  rule :student do
    # 学生首页
    nav :index, :url => '/student_home' do
      controller :index, :only => [:student_home]
    end 

    # 公共动态
    nav :dashboard, :url => '/dashboard' do
      controller :index, :only => :dashboard
    end
  end

  # 学生课程模块
  rule :student_course do
    nav :course_center, :url => '/courses' do
      controller :courses, :only => :index
    end
    
    # 我的课程
    nav :mine_courses, :url => '/courses/mine' do
      controller :courses, :only => [:mine]
    end

    # 文件共享
    nav :file_upload, :url => '/disk' do
      controller :disk
    end
  end

  # 学生作业与问答模块
  rule :student_homework do
    # 课程作业
    nav :practices, :url => '/practices' do
      controller :practices
    end
    
    # 问答
    nav :questions, :url => '/questions' do
      controller :questions
    end
  end

  # ------------------------

  rule :account do
    nav :edit, :url => '/account/edit' do
      controller :account, :only => :edit
    end
    
    nav :avatar, :url => '/account/avatar' do
      controller :account, :only => :avatar
    end

    nav :userpage, :url => '/account/userpage' do
      controller :account, :only => :userpage
    end
  end

  rule :admin_account do
    nav :password, :url => '/account/edit' do
      controller :account, :only => :edit
    end
  end

end
