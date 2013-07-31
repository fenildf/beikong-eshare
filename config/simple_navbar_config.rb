SimpleNavbar::Base.config do
  rule :admin do
    nav :users_manage, :url => '/admin/users' do
      controller :'admin/users'
    end

    nav :team_manage, :url => '/manage/teams' do
      controller :'manage/teams'
    end

    nav :course_applies_manage, :url => '/manage/applies' do
      controller :'manage/applies'
    end
    nav :teacher_surveys_manage, :url => '/manage/surveys' do
      controller :'manage/surveys'
      controller :'manage/survey_results'
    end
  end

  # 教师
  rule :teacher do
    nav :courses_manage, :url => '/manage/courses' do
      controller :'manage/courses'
      controller :'manage/chapters'
      controller :'manage/course_wares'
      controller :'manage/applies'
    end

    nav :teams, :url => '/teams' do
      controller :teams
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
  end

  # ------------------
  # 学生
  rule :student do
    nav :select_course, :url => '/select_course_intents' do
      controller :select_course_intents
    end
    
    nav :courses, :url => '/courses' do
      controller :courses
      controller :chapters
      controller :course_wares
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
