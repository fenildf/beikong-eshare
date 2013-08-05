class CourseIntent
  SELECT_COURSE_MODE = 'three'

  if SELECT_COURSE_MODE == 'one'
    extend OneCourseIntent::ClassMethods
  else
    extend SelectCourseIntent::ClassMethods
  end

  module UserMethods
    def self.included(base)
      if SELECT_COURSE_MODE == 'one'
        base.send(:include, OneCourseIntent::UserMethods)
      else
        base.send(:include, SelectCourseIntent::UserMethods)
      end
    end
  end

  module CourseMethods
    def self.included(base)
      if SELECT_COURSE_MODE == 'one'
        base.send(:include, OneCourseIntent::CourseMethods)
      else
        base.send(:include, SelectCourseIntent::CourseMethods)
      end
    end
  end

end