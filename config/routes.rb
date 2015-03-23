# -*- coding: utf-8 -*-
Eshare::Application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq_state'

  default_url_options :host => "edushare.mindpin.com" # devise 发邮件需要用到
  # 参考
  # https://github.com/plataformatec/devise/wiki/How-To:-Create-custom-layouts
  # 来设置 devise 的布局

  root :to => 'index#index'
  get '/dashboard' => 'index#dashboard'
  get '/plan' => 'index#plan'
  get '/teacher_home' => 'index#teacher_home'
  get '/admin_home' => 'index#admin_home'
  get '/student_home' => 'index#student_home'
  get '/manager_home' => 'index#manager_home'

  get '/download_attach' => 'index#download_attach'

  # bk crosslogin
  get '/bk_login' => 'index#bk_login'

  # install
  get '/install' => 'install#index'
  get '/install/:step' => 'install#step'
  post '/install/submit/:step' => 'install#step_submit'

  # /auth/weibo/callback
  get '/auth/:provider/callback' => 'oauth#callback'
  post '/auth/:provider/unbind' => 'oauth#unbind'

  # devise
  devise_for :users, :path => 'account',
                     :controllers => {
                       :registrations => :account,
                       :sessions => :sessions
                     }
  devise_scope :user do 
    get '/xk/sign_in' => 'sessions#new_xuanke'
    get '/eshare/sign_in' => 'sessions#new_eshare'
  end


  devise_scope :user do
    get 'account/avatar' => 'account#avatar'
    put 'account/avatar' => 'account#avatar_update'
    get 'account/userpage' => 'account#userpage'
    put 'account/userpage' => 'account#userpage_update'
    get '/account/sync'  => 'oauth#sync'
  end

  resources :announcements

end

# 搜索
Eshare::Application.routes.draw do
  get 'search/:query' => 'search#search'
  get 'search' => 'search#search'
end

# 标签
Eshare::Application.routes.draw do
  resources :tags do
    collection do
      put :set_tags
    end

  end

  get '/tags/courses/:tagname' => 'tags#courses'
end

# 短消息
Eshare::Application.routes.draw do
  resources :short_messages, :shallow => true do
    collection do
      get :chatlog
    end
  end
end

# 用户关系
Eshare::Application.routes.draw do
  resources :friends, :shallow => true do
    collection do
      post :follow
      post :unfollow
    end

    member do
      get :followings
      get :followers
    end
  end
end

# 个人页
Eshare::Application.routes.draw do
  resources :users, :shallow => true do
    collection do
      get :me
      get :complete_search
    end

    member do
      get :courses
      get :questions
      get :answers
      get :course_applies
    end
  end
end

# 管理员
Eshare::Application.routes.draw do
  namespace :admin do
    root :to => 'index#index'

    get 'auth_image_setting' => 'config#auth_image'
    post 'auth_image_setting' => 'config#do_auth_image'

    resources :user_groups do
      collection do
        get :teachers, :action => :index, :tab => :teachers
        get :students, :action => :index, :tab => :students

        get :users
      end

      member do
        get :add_user_form
        put :do_change_users
      end
    end

    resources :users do
      member do
        get :student_attrs
        get :teacher_attrs
        put :user_attrs_update
        put :change_password
      end

      collection do
        get :download_import_sample
        get :import
        post :do_import
      end
    end

    resources :attrs_configs do
      collection do
        get :teacher_attrs
        get :student_attrs
      end
    end 

    resources :categories do
      collection do
        post :do_import
      end
    end

    resources :user_opinions
    resources :site_changes
  end
end

# 资源网盘
Eshare::Application.routes.draw do
  post '/upload' => 'files#upload'
  post '/upload_clipboard' => 'files#upload_clipboard'
  
  post '/disk/create_folder' => 'disk#create_folder'

  get    '/disk'        => 'disk#index'
  post   '/disk/create' => 'disk#create'
  delete '/disk'        => 'disk#destroy'
  get    '/disk/file'   => 'disk#show'
  get    '/disk/share'  => 'disk#share'
  get    '/disk/s/:download_id' => 'disk#share_download'
  get    '/disk/d/:download_id' => 'disk#do_share_download'

  get    '/disk/download' => 'disk#download'

  get    '/tags/file/:tagname' => 'disk#tag_files'
end

# 问答和问答投票
Eshare::Application.routes.draw do
  resources :questions, :shallow => true do
    member do
      post :follow
      post :unfollow
    end

    collection do
      get :iask
      get :be_answered
      get :favs
      get :answered
    end

    resources :answers do
      member do
        put :vote_up
        put :vote_down
        put :vote_cancel
      end
    end
  end
end

# 课程
Eshare::Application.routes.draw do
  namespace :manage do
    resources :course_scores, :shallow => true

    resources :stats, :shallow => true do
      collection do
        get :teacher
        get :student

        get :courses
        get :plans
        get :answers
        get :problem_book
        get :progress
        get :practices
      end
    end

    resources :applies, :shallow => true do
      collection do
        get :status_request
        get :status_accept
        get :status_reject
      end
    end

    resources :practices, :shallow => true do
    end

    resources :select_course_intents, :shallow => true do
      collection do
        get :list
        get :adjust
        put :accept
        put :reject
        post :batch_check
        post :batch_check_one
      end
    end
    
    resources :course_wares, :shallow => true do
      collection do
        get :get_select_widget
      end
    end

    resources :courses, :shallow => true do
      collection do
        get :design # 课程编排

        get :download_import_sample
        get :import
        post :do_import

        get :import_youku_list
        post :import_youku_list_2
        post :do_import_youku_list

        get :import_tudou_list
        post :import_tudou_list_2
        post :do_import_tudou_list
      end

      member do
        get :check
        put :check_yes
        put :check_no
      end

      resources :chapters, :shallow => true do
        member do
          put :move_up
          put :move_down
        end

        resources :course_wares, :shallow => true do
          member do
            put :move_up
            put :move_down
            put :do_convert
            get :export_json
          end
        end
      end

      resources :applies, :shallow => true, :controller => :course_applies do
        member do
          put :accept
          put :reject
        end

        collection do
          get :status_request
          get :status_accept
          get :status_reject
        end
      end
    end

    resources :surveys, :shallow => true do
      resources :survey_results, :shallow => true
    end

    resources :announcements, :shallow => true do
      
    end

    namespace :aj do
      resources :courses, :shallow => true do
        resources :chapters, :shallow => true
      end
    end
  end
end

# 学生选课
Eshare::Application.routes.draw do
  resources :select_course_intents, :shallow => true do
    collection do
      post :save
      post :save_one # 单志愿
      delete :remove_one
    end
  end
end

# 一般用户访问课程
Eshare::Application.routes.draw do
  resources :courses, :shallow => true do
    member do
      post :checkin
      post :student_select
      get :users_rank
      get :questions
      get :notes
      get :chs

      post :dofav
      post :unfav
      post :join
      post :exit

      delete :unselect
    end

    collection do
      get :sch_select
      get :mine
      get :favs
    end

    resources :chapters, :shallow => true do
      resources :course_wares, :shallow => true do
        resources :questions, :shallow => true

        resources :javascript_steps, :shallow => true do
          member do
            post :record_input
            get :preview
          end
        end

        member do
          put :update_read_count
          post :add_video_mark
        end
      end
      resources :questions, :shallow => true
    end

    resources :course_attitudes, :shallow => true
  end
end

# 图表
Eshare::Application.routes.draw do
  namespace :charts do
    
    resources :courses, :shallow => true do
      collection do
        get :all_courses_read_pie
        get :all_courses_punch_card
        get :all_courses_select_apply_pie
      end

      member do
        get :read_pie
        get :course_intent_123_pie
      end

      resources :chapters, :shallow => true do
        member do
          get :read_pie
        end

        resources :course_wares, :shallow => true do
          member do
            get :read_count_last_week
          end
        end
      end
    end
  end
end

# 调查
Eshare::Application.routes.draw do
  resources :surveys, :shallow => true do
    member do
      post :submit
      get :select_teacher
    end
  end
end

Eshare::Application.routes.draw do
  resources :practices, :shallow => true do
    member do 
      get :check
      post :do_submit_record
      put  :do_submit_record
    end

    collection do
      put :do_check_score
    end
  end
end

# 班级
Eshare::Application.routes.draw do
  resources :teams, :shallow => true do
    collection do
      get :mine
    end
  end
end

# 用户反馈 INTERNET
Eshare::Application.routes.draw do
  namespace :help do
    resources :user_opinions, :shallow => true
    resources :site_changes, :shallow => true
  end
end