class PracticeRecord < ActiveRecord::Base
  class Status
    SUBMITTED   = 'SUBMITTED'
    CHECKED   = 'CHECKED'
    SUBMITTED_OFFLINE = 'SUBMITTED_OFFLINE'
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
      base.has_many :records, :class_name => 'PracticeRecord', :foreign_key => :practice_id
    end

    # 学生提交作业
    def submit_by_user(user)
      self.records.create(
        :practice => self,
        :user => user,
        :submitted_at => Time.now,
        :status => PracticeRecord::Status::SUBMITTED
      )
    end

    # 学生声明已经线下提交了作业
    def submittd_offline_by_user(user, submit_desc)
      practice_record = get_record_by_user(user)
      practice_record.status = PracticeRecord::Status::SUBMITTED_OFFLINE
      practice_record.submit_desc = submit_desc
      practice_record.is_submitted_offline = true
      practice_record.submitted_offline_at = Time.now
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
      return false if _empty_records_by_user?(user)
      get_record_by_user(user).status == PracticeRecord::Status::SUBMITTED
    end

    def in_checked_status_of_user?(user)
      return false if _empty_records_by_user?(user)
      get_record_by_user(user).status == PracticeRecord::Status::CHECKED
    end

    def in_submitted_offline_of_user?(user)
      return false if _empty_records_by_user?(user)
      get_record_by_user(user).status == PracticeRecord::Status::SUBMITTED_OFFLINE
    end

    def submitted_time_by_user(user)
      get_record_by_user(user).submitted_at
    end

    def checked_time_by_user(user)
      get_record_by_user(user).checked_at
    end

    def submitted_users
      records.where(:status => PracticeRecord::Status::SUBMITTED).map do |r|
        r.user
      end
    end

    def checked_users
      records.where(:status => PracticeRecord::Status::CHECKED).map do |r|
        r.user
      end
    end

    def get_record_by_user(user)    
      self.records.where(:user_id => user.id).first
    end

    private
      def _empty_records_by_user?(user)
        self.records.where(:user_id => user.id).count == 0
      end
  end

end