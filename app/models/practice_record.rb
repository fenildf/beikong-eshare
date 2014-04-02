class PracticeRecord < ActiveRecord::Base
  class Status
    SUBMITTED   = 'SUBMITTED'
    CHECKED   = 'CHECKED'
  end

  attr_accessible :practice, :user, :submitted_at, :checked_at, :status

  belongs_to :practice
  belongs_to :user


  validates :practice, :user, :submitted_at, :presence => true
  validates_uniqueness_of :practice_id, :scope => :user_id

  # 记录用户活动
  record_feed :scene => :practice_records,
                        :callbacks => [ :create ]


  module UserMethods
    def self.included(base)
      base.has_many :practice_records
    end
  end

  module PracticeMethods
    def self.included(base)
      base.has_many :created_records, :class_name => 'PracticeRecord', :foreign_key => :practice_id
      base.has_many :submitted_users, :through => :created_records, :source => :user,
        :conditions => "practice_records.status = '#{PracticeRecord::Status::SUBMITTED}'"
      base.has_many :submitted_offline_users, :through => :created_records, :source => :user,
        :conditions => "practice_records.is_submitted_offline is true"
      base.has_many :checked_users, :through => :created_records, :source => :user,
        :conditions => "practice_records.status = '#{PracticeRecord::Status::CHECKED}'"
    end

    # 学生提交作业
    def submit_by_user(user)
      self.created_records.create(
        :practice => self,
        :user => user,
        :submitted_at => Time.now,
        :status => PracticeRecord::Status::SUBMITTED
      )
    end

    # 学生声明已经线下提交了作业
    def submittd_offline_by_user(user, submit_desc)
      practice_record = get_record_by_user(user)
      practice_record.status = PracticeRecord::Status::SUBMITTED
      practice_record.submit_desc = submit_desc
      practice_record.is_submitted_offline = true
      practice_record.submitted_at = Time.now
      practice_record.save
    end

    # 老师验收作业
    def check_by_user(user, score,comment)
      practice_record = get_record_by_user(user)

      practice_record.status = PracticeRecord::Status::CHECKED
      practice_record.checked_at = Time.now
      practice_record.score = score
      practice_record.comment = comment
      practice_record.save
    end

    def in_submitted_status_of_user?(user)
      record = get_record_by_user(user)
      record.present? && record.status == PracticeRecord::Status::SUBMITTED
    end

    def in_checked_status_of_user?(user)
      record = get_record_by_user(user)
      record.present? && record.status == PracticeRecord::Status::CHECKED
    end

    def in_submitted_offline_of_user?(user)
      record = get_record_by_user(user)
      record.present? && record.is_submitted_offline?
    end

    def get_record_by_user(user)    
      self.created_records.where(:user_id => user.id).first
    end
  end

end