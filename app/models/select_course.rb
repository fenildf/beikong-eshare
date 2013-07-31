class SelectCourse < ActiveRecord::Base
  STATUS_REJECT = 'reject'
  STATUS_ACCEPT = 'accept'

  attr_accessible :course, :user, :status

  belongs_to :course
  belongs_to :user

  validates :course, :user, :presence => true
  validates :user_id,  :uniqueness => {:scope => :course_id}
  validates :status, :inclusion => { :in => [ STATUS_REJECT, STATUS_ACCEPT] }

  scope :by_course, lambda{|course| {:conditions => ['course_id = ?', course.id]} }

  def self.course_status_stat
    sql = %~
      SELECT C.id, C.name, C.apply_request_limit, count(SCA.id) AS CO FROM courses AS C
      LEFT JOIN select_courses AS SCA 
      ON SCA.course_id = C.id
      GROUP BY C.id
    ~

    re = Course.find_by_sql sql

    stat = {
      :notfull => 0, :full => 0, :over => 0, :empty => 0
    }

    re.map { |x|
      limit = x[:apply_request_limit]
      count = x[:CO]

      if count == 0
        stat[:empty] = stat[:empty] + 1 
        next
      end

      if limit == -1
        stat[:notfull] = stat[:notfull] + 1 
        next
      end

      stat[:notfull] = stat[:notfull] + 1 if limit > count 
      stat[:full] = stat[:full] + 1 if limit == count 
      stat[:over] = stat[:over] + 1 if limit < count 
    }

    stat
  end

  def self._subsql
    %~
      SELECT C.*, C.apply_request_limit AS LIM, count(SCA.id) AS CO FROM courses AS C
      LEFT JOIN select_courses AS SCA 
      ON SCA.course_id = C.id
      GROUP BY C.id
    ~
  end

  def self.empty_courses
    Course.from("(#{self._subsql}) AS courses").where("courses.CO = 0")
  end

  def self.over_courses
    Course.from("(#{self._subsql}) AS courses").where("courses.CO > courses.LIM AND courses.LIM <> -1")
  end

  def self.full_courses
    Course.from("(#{self._subsql}) AS courses").where("courses.CO = courses.LIM AND courses.LIM <> -1")
  end

  def self.notfull_courses
    Course.from("(#{self._subsql}) AS courses").where("(courses.CO < courses.LIM OR courses.LIM = -1) AND (courses.CO <> 0)")
  end

  def self.select_apply_status_courses(label)
    return self.empty_courses if label == 'empty'
    return self.over_courses if label == 'over'
    return self.full_courses if label == 'full'
    return self.notfull_courses if label == 'notfull'
  end

  module CourseMethods
    def self.included(base)
      base.has_many :select_courses, :dependent => :delete_all
      base.has_many :selected_users, :through => :select_courses, :source => :user,
        :conditions => "select_courses.status = '#{STATUS_ACCEPT}'"
      base.has_many :be_reject_selected_users, :through => :select_courses, :source => :user,
        :conditions => "select_courses.status = '#{STATUS_REJECT}'"
    end

    # 是否有选课人数上限限制
    def have_apply_request_limit?
      self.apply_request_limit.present? && self.apply_request_limit > 0
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :select_course_records, :class_name => "SelectCourse"
      base.has_many :selected_courses, :through => :select_course_records, :source => :course,
        :conditions => "select_courses.status = '#{STATUS_ACCEPT}'"
      base.has_many :be_reject_selected_courses, :through => :select_course_records, :source => :course,
        :conditions => "select_courses.status = '#{STATUS_REJECT}'"
    end

    # 用户发起一个选课请求
    def select_course(status, course)
      record = self.select_course_records.by_course(course).first
      if record.blank?
        self.select_course_records.create :course => course, :status => status.to_s
      else
        record.update_attributes(:status => status.to_s)
      end
    end

  end

end