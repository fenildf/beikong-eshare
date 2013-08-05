class CourseTeacher < ActiveRecord::Base
  attr_accessible :course, :teacher_user

  belongs_to :course
  belongs_to :teacher_user, :class_name => 'User'

  validates :course,       :presence => true
  validates :teacher_user, :presence => true

  scope :by_user, lambda{|user| {:conditions => ['teacher_user_id = ?', user.id]} }

  module CourseMethods
    def self.included(base)
      base.has_many :course_teachers

      base.has_many :teacher_users, #查询课程的任何老师 不包括 course.creator
                    :through => :course_teachers, 
                    :source => :teacher_user  
    end

    def add_teacher_user(user) #增加任课老师，不能是 course.creator
      return false if self.teacher_users.include?(user)
      self.course_teachers.create(:teacher_user => user)
    end

    def remove_teacher_user(user) #删除任课老师
      self.course_teachers.by_user(user).destroy_all
    end

    # courser.creator #查询课程的主要负责人

  end

end