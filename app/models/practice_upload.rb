class PracticeUpload < ActiveRecord::Base
  include Attachment::ModelMethods

  attr_accessible :practice, :creator

  belongs_to :practice
  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id

  validates :practice, :creator, :presence => true
  
  scope :by_creator, lambda{|creator| where(:creator_id => creator.id) }
end