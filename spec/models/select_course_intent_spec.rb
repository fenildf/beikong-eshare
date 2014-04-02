require 'spec_helper'

if R::SELECT_COURSE_MODE == 'THREE'
describe SelectCourseIntent do
  let(:user)     {FactoryGirl.create :user}
  let(:course)  {FactoryGirl.create :course}

  let(:course1)  {FactoryGirl.create :course, :approve_status => Course::APPROVE_STATUS_YES}
  let(:course2)  {FactoryGirl.create :course, :approve_status => Course::APPROVE_STATUS_YES}
  let(:course3)  {FactoryGirl.create :course, :approve_status => Course::APPROVE_STATUS_YES}
  let(:opinion) {"opinion opinion opinion opinion 4"}

  describe '设置' do
    context "set 志愿" do
      it{
        user.set_select_course_intent(:first, course1)
        user.select_course_intent.first_course.should eq course1
      }
      it{
        user.set_select_course_intent(:second, course2)
        user.select_course_intent.second_course.should == course2
      }
      it{
        user.set_select_course_intent(:third, course3)
        user.select_course_intent.third_course.should == course3
      }
    end
    context "set 志愿 没有审批 重复" do
      it{
        user.set_select_course_intent(:first, course1)
        user.set_select_course_intent(:second, course1)
        user.select_course_intent.second_course.should == nil
      }
      it{
        user.set_select_course_intent(:third, course)
        user.select_course_intent.third_course.should == nil
      }
    end

  end


  describe '查询' do
    context "get 志愿" do
      it{
        user.set_select_course_intent(:first, course1)
        user.course_intent(:first).should == course1
      }
      it{
        user.set_select_course_intent(:second, course2)
        user.course_intent(:second).should == course2
      }
      it{
        user.set_select_course_intent(:third, course3)
        user.course_intent(:third).should == course3
      }
    end

  end
end
end