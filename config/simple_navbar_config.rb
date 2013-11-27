SimpleNavbar::Base.config do
  rule :admin do
    nav :index, :url => '/admin_home' do
      controller :index, :only => [:admin_home]
    end

    nav :users_manage, :url => '/admin/users' do
      controller :'admin/users'
    end

    nav :select_course, :url => '/manage/select_course_intents' do
      controller :'manage/select_course_intents'
    end
    
    nav :courses, :url => '/courses' do
      controller :courses
      controller :chapters
      controller :course_wares
    end

    nav :teacher_surveys_manage, :url => '/manage/surveys' do
      controller :'manage/surveys'
      controller :'manage/survey_results'
    end
  end

  # 教务管理
  rule :manager do
    nav :courses_check, :url => '/manage/courses' do
      controller :'manage/courses'
      controller :'manage/chapters'
      controller :'manage/course_wares'
      controller :'manage/applies'
    end

    nav :select_course, :url => '/manage/select_course_intents' do
      controller :'manage/select_course_intents'
    end

    nav :courses, :url => '/courses' do
      controller :courses
      controller :chapters
      controller :course_wares
    end

    nav :announcements, :url => '/manage/announcements' do
      controller :'manage/announcements'
      controller :announcements
    end
  end

  # 教师
  rule :teacher do
    # 教师首页
    nav :index, :url => '/teacher_home' do
      controller :index, :only => [:teacher_home]
    end

    # 课程申报
    nav :course_submit, :url => '/manage/courses' do
      controller :'manage/courses', :only => [:index, :new, :edit]
    end

    # 课程编排
    nav :course_design, :url => '/manage/courses/design' do
      controller :'manage/courses', :except => [:index, :new, :edit]
      controller :'manage/chapters'
    end

    # 上传课件
    nav :course_ware_upload, :url => '/manage/course_wares/new' do
      controller :'manage/course_wares'
    end

    # 课程中心
    nav :courses, :url => '/courses' do
      controller :courses
    end

    # 布置作业
    nav :new_practice, :url => '/manage/practices/new' do
      controller :'manage/practices', :only => [:new]
    end

    # 检查作业
    nav :check_practice, :url => '/manage/practices' do
      controller :'manage/practices', :except => [:new] 
    end

    # 成绩登记
    nav :course_scores, :url => '/manage/course_scores' do
      controller :'manage/course_scores'
    end

    # 文件共享
    nav :file_upload, :url => '/disk' do
      controller :disk
    end

    # 在线答疑
    nav :questions, :url => '/questions' do
      controller :'questions'
    end

    # 好友关注
    nav :friends, :url => '/friends' do
      controller :friends
    end 

    # 发布公告
    nav :new_announcements, :url => '/manage/announcements/new' do
      controller :'manage/announcements'
    end

    # 查看公告
    nav :announcements, :url => '/announcements' do
      controller :announcements
    end

    # 我的班级
    nav :my_teams, :url => '/teams/of_teacher' do
      controller :teams
    end

    # 统计信息
    nav :stat, :url => '/manage/stats/teacher' do
      controller :'manage/stats'
    end
  end

  # 学生
  rule :student do
    # 学生首页
    nav :index, :url => '/student_home' do
      controller :index, :only => [:student_home]
    end

    nav :select_course, :url => '/select_course_intents' do
      controller :select_course_intents
    end
    
    nav :courses, :url => '/courses' do
      controller :courses
      controller :chapters
      controller :course_wares
    end

    nav :practices, :url => '/practices' do
      controller :practices
    end

    nav :file_upload, :url => '/disk' do
      controller :disk
    end

    nav :questions, :url => '/questions' do
      controller :questions
    end

    # 好友关注
    nav :friends, :url => '/friends' do
      controller :friends
    end 

    nav :dashboard, :url => '/dashboard' do
      controller :index, :only => :dashboard
    end

    nav :announcements, :url => '/announcements' do
      controller :announcements
    end

    nav :user, :url => '/users/me' do
      controller :users
    end

    # 我的班级
    nav :my_teams, :url => '/teams/of_teacher' do
      controller :teams
    end

    # 统计信息
    nav :stat, :url => '/manage/stats/teacher' do
      controller :'manage/stats'
    end

    nav :'teacher-surveys', :url => '/surveys' do
      controller :surveys
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
