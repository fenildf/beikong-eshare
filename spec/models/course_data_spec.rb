require "spec_helper"

describe CourseData do

  describe CourseData::CourseMethods do
    context "relations" do
      let(:course_data) {FactoryGirl.create :course_data}
      let(:file_entity) {course_data.file_entity}
      let(:course)      {course_data.course}
      subject           {course}

      its(:course_datas)       {should include course_data}
      its(:data_file_entities) {should include file_entity}
    end

    describe "#add_file_entity" do
      let(:file_entity) {FactoryGirl.create :file_entity}
      let(:course)      {FactoryGirl.create :course}
      subject           {course.add_file_entity(file_entity)}
      
      it {expect {subject}.to change {course.course_datas.count}.by(1)}
      it {expect {subject}.to change {course.data_file_entities.count}.by(1)}
      its(:file_entity) {should eq file_entity}
      its(:course)      {should eq course}
    end
  end
end
