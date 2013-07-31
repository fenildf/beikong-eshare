require "spec_helper"

describe SelectCourse do
  before{
    @user = FactoryGirl.create(:user)
    @course = FactoryGirl.create(:course)
    @user2 = FactoryGirl.create(:user)
    @course2 = FactoryGirl.create(:course)
  }

  context 'select_course(:accept, course)' do
    before{
      @user.select_course(:accept, @course)
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

  context 'select_course(:accept, course)' do
    before{
      @user.select_course(:reject, @course)
      @user.reload
      @course.reload
    }

    it{
      @user.be_reject_selected_courses.should == [@course]
    }

    it{
      @course.be_reject_selected_users.should == [@user]
    }
  end

  context '综合测试' do
    before{
      @user.select_course(:accept, @course)
      @user2.select_course(:reject, @course)
      @user.select_course(:accept, @course2)
      @user2.select_course(:reject, @course2)

      @user.reload
      @course.reload
      @user2.reload
      @course2.reload
    }

    it{
      @user.be_reject_selected_courses.should =~ []
      @user2.be_reject_selected_courses.should =~ [@course, @course2]
    }

    it{
      @user.selected_courses.should =~ [@course, @course2]
      @user2.selected_courses.should =~ []
    }

    it{
      @course.be_reject_selected_users.should == [@user2]
      @course2.be_reject_selected_users.should == [@user2]
    }

    it{
      @course.selected_users.should == [@user]
      @course2.selected_users.should == [@user]
    }

  end

end