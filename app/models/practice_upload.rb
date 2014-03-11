class PracticeUpload < ActiveRecord::Base
  attr_accessible :practice, :creator, :file_entity, :name

  belongs_to :practice
  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  belongs_to :file_entity


  validates :practice, :creator, :file_entity, :name, :presence => true

end