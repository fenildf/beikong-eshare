require 'spec_helper'

describe Team do
  let(:teacher_user) {FactoryGirl.create :user}

  it "用户创建Team" do
    expect{
      teacher_user.teams.create(:name => "张三")
    }.to change{Team.count}.by(1)
  end


  context "查询用户创建的 teams" do
    before{ 
      teacher_user.teams.create(:name => "张三1")
      teacher_user.teams.create(:name => "张三2") 
      teacher_user.teams.create(:name => "张三3")
    }
    it{
      teacher_user.manage_teams.count.should == 3
    }
  end
end