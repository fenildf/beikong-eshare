class Announcement < ActiveRecord::Base
  FOR_ROLE_TEACHER = 'TEACHER'
  FOR_ROLE_STUDENT = 'STUDENT'

  default_scope order('id desc')
  attr_accessible :title, :content, :creator_id

  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  has_many :announcement_users

  validates :creator, :title, :content, :presence => true
  validates :for_role, :inclusion => { :in => [FOR_ROLE_TEACHER, FOR_ROLE_STUDENT]}

  scope :with_role_teacher, :conditions => ['announcements.for_role = ?', FOR_ROLE_TEACHER]
  scope :with_role_student, :conditions => ['announcements.for_role = ?', FOR_ROLE_STUDENT]

  after_save :read_by_user
  def read_by_user(user = creator)
    self.announcement_users.create(:user => user, :read => true)
  end

  def has_readed?(user)
    self.announcement_users.by_user(user).count == 1
  end


  module UserMethods
    def self.included(base)
      base.has_many :announcements, :foreign_key => 'creator_id'
    end
  end
end
