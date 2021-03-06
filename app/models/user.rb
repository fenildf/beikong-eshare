# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # :recoverable
  devise :database_authenticatable, :registerable, 
         :rememberable, :trackable, :validatable,
         :recoverable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :password, :gender, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  validates :login, :format => {:with => /\A[\w-]+\z/, :message => '只允许数字、字母和下划线'},
                    :length => {:in => 3..20},
                    :presence => true,
                    :uniqueness => {:case_sensitive => false}

  validates :name, :presence => true

  default_scope order('users.id DESC')

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    self.where(:login => login).first
  end

  # 关闭 devise 验证 email 的逻辑
  def email_required?
    false
  end

  # ------------ 以上是用户登录相关代码，不要改动
  # ------------ 任何代码请在下方添加

  validates :tagline, :length => {:in => 0..150}

  # 管理员修改基本信息
  attr_accessible :login, :name, :role, :as => :manage_change_base_info
  # 修改基本信息
  attr_accessible :login, :name, :as => :change_base_info
  # 修改密码
  attr_accessible :password, :password_confirmation, :as => :change_password

  # MediaResource
  include MediaResource::UserMethods

  # carrierwave
  mount_uploader :avatar, AvatarUploader
  attr_accessible :name, :tagline, :avatar
  attr_accessor :avatar_cw, :avatar_ch, :avatar_cx, :avatar_cy

  mount_uploader :userpage_head, UserPageHeadUploader
  attr_accessible :userpage_head

  # 声明角色
  attr_accessible :role
  validates :role, :presence => true
  roles_field :roles_mask, :roles => [:admin, :manager, :teacher, :student]

  before_validation :set_default_role
  def set_default_role
    self.role = :student if self.role.blank?
  end

  # 分别为学生和老师增加动态字段
  include DynamicAttr::Owner
  has_dynamic_attrs :student_attrs,
                    :updater => lambda {AttrsConfig.get(:student)}
  has_dynamic_attrs :teacher_attrs,
                    :updater => lambda {AttrsConfig.get(:teacher)}

  # 导入文件
  simple_excel_import :teacher, :fields => [:login, :name, :gender],
                                :default => {:role => :teacher}

  simple_excel_import :student, :fields => [:login, :name, :gender],
                                :default => {:role => :student}

  def self.import_excel(excel_file, role, password = '1234')
    users = self.parse_excel_student excel_file if role == :student
    users = self.parse_excel_teacher excel_file if role == :teacher

    users.each do |u|
      u.password = password
      u.password_confirmation = password
      u.save
    end
  end

  scope :like_filter, lambda { |query|
    if query.blank?
      { :conditions => ['TRUE'] }
    else
      {
        :conditions => [
          'login like ? OR name like ? OR id = ?',
          "%#{query}%", "%#{query}%", query, query
        ]
      }
    end
  }

  # 用户自定义 tag
  simple_taggable


  def self.create_of_find_oauth_sign_user(oauth_hash)
    return nil if R::INHOUSE
  end

  # 判断是否还没有补充邮箱，密码等信息的只能用oauth登录的临时用户
  def is_oauth_sign_temp_user?
    return false if R::INHOUSE
  end

  def follow(model)
    model.follow_by_user self
  end

  def unfollow(model)
    model.unfollow_by_user self
  end

  # 记录用户 增加/修改 个人签名档
  record_feed :scene => :users,
                        :callbacks => [ :update ],
                        :before_record_feed => lambda {|user, callback_type|
                          return user.tagline_changed?
                        },
                        :set_feed_data => lambda {|user, callback_type|
                          return user.tagline
                        }

  include Redis::Search
  redis_search_index :title_field => :name,
                     :prefix_index_enable => true,
                     :condition_fields => [:is_admin?, :is_teacher?, :is_student?],
                     :ext_fields => [:normal_avatar_url]

  def normal_avatar_url
    avatar.versions[:normal].url
  end

  include Course::UserMethods
  include Question::UserMethods
  include Answer::UserMethods
  include AnswerVote::UserMethods
  include Announcement::UserMethods
  include Follow::UserMethods
  include QuestionFollow::UserMethods
  include Practice::UserMethods
  include PracticeRecord::UserMethods
  include Activity::UserMethods
  include UserFeedStream
  include MediaShare::UserMethods
  include QuestionFeedTimelime::UserMethods
  include ShortMessage::UserMethods
  include CourseFav::UserMethods
  include SelectCourse::UserMethods
  include CourseWareReading::UserMethods
  include TagFollow::UserMethods
  include Omniauth::UserMethods
  include WeiboFriends
  include Note::UserMethods
  include CourseAttitude::UserMethods
  include Medal::UserMethods
  include SimpleCredit::UserMethods
  include Report::UserMethods
  include CourseScore::UserMethods
  include CourseIntent::UserMethods
  include CourseWare::UserMethods
  include UserGenderMethods
  include GroupTreeNode::UserMethods
  include GroupTreeNodeUser::UserMethods
end