require 'spec_helper'

describe Team do
  context '创建 team' do
    before{
      @team = Team.create!(:name => 'xxx')
    }

    it{
      @team.id.present?.should == true
    }

    context '给 team 设置班主任' do
      before{
        @teacher_user = FactoryGirl.create :user
        @team.update_attributes(:teacher_user => @teacher_user)
        @team.reload
      }

      it{
        @team.teacher_user.should == @teacher_user
      }

      it{
        @teacher_user.manage_teams.should == [@team]
      }
    end
  end

end