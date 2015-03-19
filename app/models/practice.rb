class Practice < ActiveRecord::Base
  include PracticeRecord::PracticeMethods
  include Attachment::ModelMethods

  attr_accessible :title, :content, :chapter, :creator

  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  belongs_to :chapter

  has_many :uploads, :class_name => 'PracticeUpload', :foreign_key => :practice_id

  validates :title, :chapter, :creator, :presence => true

  scope :by_creator, lambda{|creator| where(:creator_id => creator.id) }
  scope :by_course, lambda{|course| joins(:chapter).where('chapters.course_id = ?', course.id) }

  default_scope order('created_at desc')

  def add_upload(user, file_entity)
    upload = self.uploads.by_creator(user).first
    if upload.blank?
      upload = self.uploads.create(:creator => user)
    end
    upload.file_entities << file_entity
  end

  def remove_upload(user, file_entity)
    upload = self.uploads.by_creator(user).first
    return if upload.blank?
    upload.file_entities.delete file_entity
  end

  module UserMethods
    def self.included(base)
      base.has_many :practices, 
                    :class_name => 'Practice', 
                    :foreign_key => :creator_id

      # 被分配的作业
      base.has_many :assigned_practices,
                    :through => :selected_courses,
                    :source => :practices
    end
  end

end
