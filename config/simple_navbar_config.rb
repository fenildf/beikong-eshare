SimpleNavbar::Base.config do
  rule :admin do
    nav :index, :url => '/admin_home' do
      controller :index, :only => [:admin_home]
    end

    nav :users_manage, :url => '/admin/user_groups' do
      controller :'admin/user_groups'
    end

    nav :categories_manage, :url => '/admin/categories' do
      controller :'admin/categories'
    end
  end

  # 教学领导
  rule :manager do
    # 领导首页
    nav :index, :url => '/manager_home' do
      controller :index, :only => [:manager_home]
    end

    nav :courses_check, :url => '/manage/courses' do
      controller :'manage/courses'
      controller :'manage/chapters'
      controller :'manage/course_wares'
      controller :'manage/applies'
    end

    nav :stat_courses, :url => '/manage/stats/courses' do
      controller :'manage/stats', :only => [:courses]
    end

    nav :stat_plans, :url => '/manage/stats/plans' do
      controller :'manage/stats', :only => [:plans]
    end

    nav :stat_answers, :url => '/manage/stats/answers' do
      controller :'manage/stats', :only => [:answers]
    end

    nav :stat_problem_book, :url => '/manage/stats/problem_book' do
      controller :'manage/stats', :only => [:problem_book]
    end

    nav :stat_progress, :url => '/manage/stats/progress' do
      controller :'manage/stats', :only => [:progress]
    end

    nav :stat_practices, :url => '/manage/stats/practices' do
      controller :'manage/stats', :only => [:course_create]
    end

    nav :teacher_surveys_manage, :url => '/manage/surveys' do
      controller :'manage/surveys'
      controller :'manage/survey_results'
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

    nav :course_submit, :url => '/manage/courses' do
      controller :'manage/courses', :only => [:index]
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

    # 回答过的问题
    nav :questions_answered, :url => '/questions/answered' do
      controller :questions, :only => [:answered]
    end

    # 关注的问题
    nav :questions_fav, :url => '/questions/favs' do
      controller :questions, :only => [:favs]
    end

    # 好友关注
    nav :friends, :url => '/friends' do
      controller :friends
    end 

    # 公共动态
    nav :dashboard, :url => '/dashboard' do
      controller :index, :only => :dashboard
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
    nav :my_teams, :url => '/teams/mine' do
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

    # 好友关注
    nav :friends, :url => '/friends' do
      controller :friends
    end 

    # 公共动态
    nav :dashboard, :url => '/dashboard' do
      controller :index, :only => :dashboard
    end

    # 公告查看
    nav :announcements, :url => '/announcements' do
      controller :announcements
    end

    # 我的班级
    nav :my_teams, :url => '/teams/mine' do
      controller :teams
    end

    # 统计信息
    nav :stat, :url => '/manage/stats/student' do
      controller :'manage/stats'
    end

    # 教师评价
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
