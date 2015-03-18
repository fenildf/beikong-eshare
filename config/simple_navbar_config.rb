SimpleNavbar::Base.config do
  rule :admin do
    nav :users_manage, :url => '/admin/users' do
      controller :'admin/users'
    end

    nav :courses_manage, :url => '/manage/courses' do
      controller :'manage/courses'
      controller :'manage/chapters'
      controller :'manage/course_wares'
    end

    # nav :teacher_surveys_manage, :url => '/manage/surveys' do
    #   controller :'manage/surveys'
    #   controller :'manage/survey_results'
    # end

    nav :user_groups_manage, :url => '/manage/user_groups' do
    end
  end

  # 教师
  rule :teacher_course do
    # 编辑课程
    nav :course_design, :url => '/manage/courses' do
      controller :'manage/courses'
      controller :'manage/chapters'
      controller :'manage/course_wares'
    end

    # 文件共享
    nav :file_upload, :url => '/disk' do
      controller :disk
    end
  end

  rule :teacher_homework do
    # 布置作业
    nav :new_practice, :url => '/manage/practices/new' do
      controller :'manage/practices', :only => [:new]
    end

    # 检查作业
    nav :check_practice, :url => '/manage/practices' do
      controller :'manage/practices', :except => [:new] 
    end

    # 提出的问题
    nav :questions_iask, :url => '/questions/iask' do
      controller :questions, :only => [:iask]
    end

    # 得到回答的问题
    nav :questions_be_answered, :url => '/questions/be_answered' do
      controller :questions, :only => [:be_answered]
    end

    # 回答过的问题
    nav :questions_answered, :url => '/questions/answered' do
      controller :questions, :only => [:answered]
    end

    # 关注的问题
    nav :questions_fav, :url => '/questions/favs' do
      controller :questions, :only => [:favs]
    end
  end

  rule :teacher_other do
    # 公共动态
    nav :dashboard, :url => '/dashboard' do
      controller :index, :only => :dashboard
    end

    # 发布公告
    nav :new_announcements, :url => '/manage/announcements/new' do
      controller :'manage/announcements'
    end
  end

  # 学生
  rule :student do
    # 学生首页
    nav :index, :url => '/student_home' do
      controller :index, :only => [:student_home]
    end
    
    # 我的课程
    nav :mine_courses, :url => '/courses/mine' do
      controller :courses, :only => [:mine]
    end

    # 收藏的课程
    nav :fav_courses, :url => '/courses/favs' do
      controller :courses, :only => [:favs]
    end

    # 课程作业
    nav :practices, :url => '/practices' do
      controller :practices
    end

    # 文件共享
    nav :file_upload, :url => '/disk' do
      controller :disk
    end

    # 提出的问题
    nav :questions_iask, :url => '/questions/iask' do
      controller :questions, :only => [:iask]
    end

    # 得到回答的问题
    nav :questions_be_answered, :url => '/questions/be_answered' do
      controller :questions, :only => [:be_answered]
    end

    # 关注的问题
    nav :questions_fav, :url => '/questions/favs' do
      controller :questions, :only => [:favs]
    end

    # 公共动态
    nav :dashboard, :url => '/dashboard' do
      controller :index, :only => :dashboard
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

    if R::INTERNET
      nav :sync, :url => '/account/sync' do
        controller :oauth, :only => :sync
      end
    end
  end

  rule :admin_account do
    nav :password, :url => '/account/edit' do
      controller :account, :only => :edit
    end
  end
end
