class SelectCourseIntent < ActiveRecord::Base
  attr_accessible :user, 
                  :first_course, 
                  :second_course, 
                  :third_course, 
                  :opinion

  belongs_to :user

  belongs_to :first_course,  :class_name => "Course"
  belongs_to :second_course, :class_name => "Course"
  belongs_to :third_course,  :class_name => "Course"

  validates :user, :presence => true


  module UserMethods
    def self.included(base)
      base.has_one :select_course_intent, :foreign_key => 'user_id'
    end

    def set_first_select_course_intent(course)
      return if !_check_course?(course)
      self.select_course_intent.update_attributes :first_course => course
    end

    def set_second_select_course_intent(course)
      return if !_check_course?(course)
      self.select_course_intent.update_attributes :second_course => course
    end

    def set_third_select_course_intent(course)
      return if !_check_course?(course)
      self.select_course_intent.update_attributes :third_course => course
    end

    def set_select_course_intent_opinion(opinion)
      self.select_course_intent.update_attributes :opinion => opinion
    end

    # ----------------

    def first_select_course_intent
      self.select_course_intent.first_course
    end

    def second_select_course_intent
      self.select_course_intent.second_course
    end

    def third_select_course_intent
      self.select_course_intent.third_course
    end

    def select_course_intent_opinion
      self.select_course_intent.opinion
    end

    # ----------------

    def select_course_intent
      SelectCourseIntent.where(:user_id => self.id).first || SelectCourseIntent.create(:user => self)
    end

    private
      def _check_course?(course)
        approved      = Course.approved.include?(course)
        check_first   = course != self.select_course_intent.first_course
        check_second  = course != self.select_course_intent.second_course
        check_third   = course != self.select_course_intent.third_course
        approved && check_first && check_second && check_third
      end
  end
end