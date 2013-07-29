require 'spec_helper'

describe CourseScore do

  before {
    @student_user_1 = FactoryGirl.create(:user)
    @student_user_2 = FactoryGirl.create(:user)

    @course_1 = FactoryGirl.create(:course)
    @course_2 = FactoryGirl.create(:course)
  }

  it "student_user_1" do
    @course_1.get_score_of_user(@student_user_1).should == nil
  end


  describe "course_1 set_score" do
    before {
      @course_1._score(@student_user_1, '70')
    }

    it "score" do
      @course_1.get_score_of_user(@student_user_1).should == 70
    end

    describe "course_1 set_score" do
      before {
        @course_1._score(@student_user_1, '90')
      }

      it "score" do
        @course_1.get_score_of_user(@student_user_1).should == 90
      end
    end

  end

end