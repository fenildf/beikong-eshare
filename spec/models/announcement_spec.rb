require "spec_helper"

describe Announcement do
  before {
    @course = FactoryGirl.create(:course)
    @user = FactoryGirl.create(:user)

    @announcement_1 = FactoryGirl.create(:announcement, :host => @course)

    3.times {
      FactoryGirl.create(:announcement, :host_type => 'System')
    }

    
    
  }

  it "course 通知" do
    @course.announcements.first.should == @announcement_1
  end

  it "course 数量" do
    @course.announcements.length.should == 1
  end

  it "manager 数量" do
    Announcement.by_manager.length.should == 3
  end

end