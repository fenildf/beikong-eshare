require "spec_helper"

describe AnnouncementUser do
  describe 'Validation' do
    before {
      @creator = FactoryGirl.create(:user, id: 1000)
      @user = FactoryGirl.create(:user, :role => :student)

      @announcement = FactoryGirl.create(:announcement, creator: @creator, for_role: Announcement::FOR_ROLE_STUDENT)
    }

    it "其它用户还没有通知记录" do
      @announcement.announcement_users.by_user(@user).count.should == 0
    end
    
    it "其它用户应该是未读通知" do
      @announcement.has_readed?(@user).should == false
    end

    it "通知创建者应该有已读记录" do
      @announcement.announcement_users.by_user(@creator).count.should == 1
    end
    
    it "通知创建者应该是已读通知" do
      @announcement.has_readed?(@creator).should == true
    end

    it "其它用户应该有通知记录" do
      @announcement.read_by_user(@user)
      @announcement.announcement_users.by_user(@user).count.should == 1
    end


    it "其它用户应该设置成已读" do
      @announcement.read_by_user(@user)
      @announcement.has_readed?(@user).should == true
    end

  end

  describe 'on top' do
    before {
      @creator = FactoryGirl.create(:user, id: 1000)
      @user = FactoryGirl.create(:user, :role => :student)

      @announcement1 = FactoryGirl.create(:announcement, creator: @creator, for_role: Announcement::FOR_ROLE_STUDENT)
      @announcement2 = FactoryGirl.create(:announcement, creator: @creator, for_role: Announcement::FOR_ROLE_STUDENT)

      @announcement3 = FactoryGirl.create(:announcement, creator: @creator, for_role: Announcement::FOR_ROLE_TEACHER)
      @announcement4 = FactoryGirl.create(:announcement, creator: @creator, for_role: Announcement::FOR_ROLE_TEACHER)
    }

    it {
      Announcement.with_on_top.count.should == 0
    }

    it {
      Announcement.with_on_top.count.should == 0
      Announcement.without_on_top.count.should == 4
      @announcement1.set_on_top
      Announcement.with_on_top.should == [@announcement1]
      @announcement2.set_on_top
      Announcement.with_on_top.should == [@announcement2]
      @announcement3.set_on_top
      Announcement.with_on_top.should =~ [@announcement2, @announcement3]
      @announcement4.set_on_top
      Announcement.with_on_top.should =~ [@announcement2, @announcement4]
      Announcement.without_on_top.should =~ [@announcement1, @announcement3]
    }
  end
end