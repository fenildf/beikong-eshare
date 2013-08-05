
require "spec_helper"

describe CourseTeacher do
  let(:course)  { FactoryGirl.create(:course)}
  let(:user)    { FactoryGirl.create(:user)}
  let(:user1)    { FactoryGirl.create(:user)}

  context 'add_teacher_user(user)' do
    it{
      expect{
        course.add_teacher_user(user)
      }.to change{
        CourseTeacher.all.count
      }.by(1)
    }

    it{
      expect{
        course.add_teacher_user(user)
        course.add_teacher_user(user)
      }.to change{
        CourseTeacher.all.count
      }.by(1)
    }
  end

  context 'remove_teacher_user(user)' do
    before{
      course.add_teacher_user(user)
    }
    it{
      expect{
        course.remove_teacher_user(user1)
      }.to change{
        CourseTeacher.all.count
      }.by(0)
    }

    it{
      expect{
        course.remove_teacher_user(user)
      }.to change{
        CourseTeacher.all.count
      }.by(-1)
    }

    it{
      expect{
        course.remove_teacher_user(user)
        course.remove_teacher_user(user)
      }.to change{
        CourseTeacher.all.count
      }.by(-1)
    }
  end

  it{
    course.add_teacher_user(user)
    course.add_teacher_user(user1)

    course.teacher_users.count.should == 2
  }
end