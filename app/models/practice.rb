class Practice < ActiveRecord::Base

  attr_accessible :title, :content, :chapter, :creator, 
                  :attaches_attributes, :requirements_attributes

  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  belongs_to :chapter


  has_many :attaches, :class_name => 'PracticeAttach', :foreign_key => :practice_id
  has_many :requirements, :class_name => 'PracticeRequirement', :foreign_key => :practice_id
  has_many :records, :class_name => 'PracticeRecord', :foreign_key => :practice_id
  has_many :uploads, :through => :records

  accepts_nested_attributes_for :attaches
  accepts_nested_attributes_for :requirements


  validates :title, :chapter, :creator, :presence => true


  scope :by_creator, lambda{|creator| :creator => creator }
  scope :by_course, lambda{|course| joins(:chapters).where('chapters.course_id = ?', course) }


  def submit_by_user(user)
    self.records.create(
      :practice => self,
      :user => user,
      :submitted_at => Time.now,
      :status => PracticeRecord::Status::SUBMITTED
    )
  end


  def check_by_user(user, score,comment)
    practice_record = _get_record_by_user(user)

    practice_record.status = PracticeRecord::Status::CHECKED
    practice_record.checked_at = Time.now
    practice_record.score = score
    practice_record.comment = comment
    practice_record.save
  end


  def in_submitted_status_of_user?(user)
    return false if _empty_records_by_user?(user)
    _get_record_by_user(user).status == PracticeRecord::Status::SUBMITTED
  end

  def in_checked_status_of_user?(user)
    return false if _empty_records_by_user?(user)
    _get_record_by_user(user).status == PracticeRecord::Status::CHECKED
  end

  def in_submitted_offline_of_user?(@user)
    return false if _empty_records_by_user?(user)
    _get_record_by_user(user).status == PracticeRecord::Status::SUBMITTED_OFFLINE
  end

  def submitted_time_by_user(user)
    _get_record_by_user(user).submitted_at
  end

  def checked_time_by_user(user)
    _get_record_by_user(user).checked_at
  end


  def submitted_users
    practice.records.where(:status => PracticeRecord::Status::SUBMITTED).map do |r|
      r.users
    end
  end

  def checked_users
    practice.records.where(:status => PracticeRecord::Status::CHECKED).map do |r|
      r.users
    end
  end

  def submittd_offline_by_user(user, submit_desc)
    practice_record = _get_record_by_user(user)
    practice_record.status = PracticeRecord::Status::SUBMITTED_OFFLINE
    practice_record.submit_desc = submit_desc
    practice_record.is_submitted_offline = true
    practice_record.submitted_offline_at = Time.now
    practice_record.save
  end

  private
    def _empty_records_by_user?(user)
      self.records.where(:user_id => user.id).count == 0
    end

    def _get_record_by_user(user)    
      self.records.where(:user_id => user.id).first
    end


  module UserMethods
    def self.included(base)
      base.has_many :practices, :class_name => 'Practice', :foreign_key => :creator_id
    end
  end

end
