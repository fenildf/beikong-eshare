# -*- coding: utf-8 -*-
class CourseScore < ActiveRecord::Base

  attr_accessible :course, :student_user, :score
            
  belongs_to :course
  belongs_to :student_user, :class_name => 'User', :foreign_key => :student_user_id
  
  validates :course, :student_user, :score, :presence => true
  validates :course_id, :uniqueness => {:scope => :student_user_id}



  module UserMethods
    def self.included(base)
      base.has_many :course_scores, :class_name => 'CourseScore', :foreign_key => :student_user_id
    end
  end


  module CourseMethods
    def self.included(base)
      base.has_many :course_scores
    end

    def set_score(student_user, score)
      student_scores = student_user.course_scores.where(:course_id => id)
      if student_scores.exists?
        student_score = student_scores.first
        student_score.score = score
        student_score.save
        return student_score
      end
      student_scores.create(:score => score)
    end

    def get_score_of_user(student_user)
      student_score = student_user.course_scores.where(:course_id => id).first
      return nil if student_score.nil?

      student_score.score
    end
  end

end
