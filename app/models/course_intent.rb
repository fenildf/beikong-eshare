class CourseIntent
  if R::SELECT_COURSE_MODE == 'ONE'
    extend OneCourseIntent::ClassMethods
  else
    extend SelectCourseIntent::ClassMethods
  end

  module UserMethods
    def self.included(base)
      if R::SELECT_COURSE_MODE == 'ONE'
        base.send(:include, OneCourseIntent::UserMethods)
      else
        base.send(:include, SelectCourseIntent::UserMethods)
      end
    end
  end

  module CourseMethods
    def self.included(base)
      if R::SELECT_COURSE_MODE == 'ONE'
        base.send(:include, OneCourseIntent::CourseMethods)
      else
        base.send(:include, SelectCourseIntent::CourseMethods)
      end
    end
  end

end