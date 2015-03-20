class SelectCourse < ActiveRecord::Base

  attr_accessible :course, :user, :status

  belongs_to :course
  belongs_to :user

  validates :course, :user, :presence => true
  validates :user_id,  :uniqueness => {:scope => :course_id}

  scope :by_course, lambda{|course| {:conditions => ['course_id = ?', course.id]} }

  module CourseMethods
    def self.included(base)
      base.has_many :select_courses, :dependent => :delete_all
      base.has_many :selected_users, :through => :select_courses, :source => :user
    end

    def is_selected_by?(user)
      record = user.select_course_records.by_course(self).first
      !record.blank?
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :select_course_records, :class_name => "SelectCourse"
      base.has_many :selected_courses, :through => :select_course_records, :source => :course
    end

    # 用户选课
    def select_course(course)
      record = self.select_course_records.by_course(course).first
      if record.blank?
        self.select_course_records.create :course => course
      end
    end

    def cancel_select_course(course)
      record = self.select_course_records.by_course(course).first
      if record
        record.destroy
      end
    end

  end

end