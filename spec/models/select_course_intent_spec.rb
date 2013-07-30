require 'spec_helper'

describe SelectCourseIntent do
  let(:user)     {FactoryGirl.create :user}
  let(:course)  {FactoryGirl.create :course}

  let(:course1)  {FactoryGirl.create :course, :is_approved => true}
  let(:course2)  {FactoryGirl.create :course, :is_approved => true}
  let(:course3)  {FactoryGirl.create :course, :is_approved => true}
  let(:opinion) {"opinion opinion opinion opinion 4"}

  describe '设置' do
    context "set 志愿" do
      it{
        user.set_first_select_course_intent(course1)
        user.select_course_intent.first_course.should eq course1
      }
      it{
        user.set_second_select_course_intent(course2)
        user.select_course_intent.second_course.should == course2
      }
      it{
        user.set_third_select_course_intent(course3)
        user.select_course_intent.third_course.should == course3
      }
    end
    context "set 志愿 没有审批 重复" do
      it{
        user.set_first_select_course_intent(course1)
        user.set_second_select_course_intent(course1)
        user.select_course_intent.second_course.should == nil
      }
      it{
        user.set_third_select_course_intent(course)
        user.select_course_intent.third_course.should == nil
      }
    end

    it{
      user.set_select_course_intent_opinion(opinion)
      user.select_course_intent.opinion.should == opinion
    }
  end


  describe '查询' do
    context "get 志愿" do
      it{
        user.set_first_select_course_intent(course1)
        user.first_select_course_intent.should == course1
      }
      it{
        user.set_second_select_course_intent(course2)
        user.second_select_course_intent.should == course2
      }
      it{
        user.set_third_select_course_intent(course3)
        user.third_select_course_intent.should == course3
      }
    end

    it{
      user.set_select_course_intent_opinion(opinion)
      user.select_course_intent_opinion.should == opinion
    }
  end
end