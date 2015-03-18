require "spec_helper"

describe SelectCourse do
  before{
    @user = FactoryGirl.create(:user)
    @course = FactoryGirl.create(:course)
    @user2 = FactoryGirl.create(:user)
    @course2 = FactoryGirl.create(:course)
  }

  context 'select_course(course)' do
    before{
      @user.select_course(@course)
      @user.reload
      @course.reload
    }

    it{
      @user.selected_courses.should == [@course]
    }

    it{
      @course.selected_users.should == [@user]
    }
  end

end