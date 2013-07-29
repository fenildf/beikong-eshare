class CourseData < ActiveRecord::Base
  attr_accessible :file_entity

  belongs_to :course
  belongs_to :file_entity

  module CourseMethods
    def self.included(base)
      base.has_many(:course_datas)
      base.has_many(:data_file_entities,
                    :through => :course_datas,
                    :source  => :file_entity)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def add_file_entity(file_entity)
        self.course_datas.create(:file_entity => file_entity)
      end
    end
  end
end
