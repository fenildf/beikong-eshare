# -*- coding: utf-8 -*-
class CourseScore < ActiveRecord::Base

  attr_accessible :course, :student_user, :score
            
  belongs_to :course
  belongs_to :student_user, :class_name => 'User', :foreign_key => :student_user_id
  
  validates :course, :student_user, :score, :presence => true
  validates :course_id, :uniqueness => {:scope => :student_user_id}
end
