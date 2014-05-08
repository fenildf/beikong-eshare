# 学生提交的作业附件
# 目前此模型和 practice_record 没有关联关系
# 参考 http://s.4ye.me/xcw8p4

class PracticeUpload < ActiveRecord::Base
  include Attachment::ModelMethods

  attr_accessible :practice, :creator

  belongs_to :practice
  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id

  validates :practice, :creator, :presence => true
  
  scope :by_creator, lambda{|creator| where(:creator_id => creator.id) }
end