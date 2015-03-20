require 'spec_helper'

describe GroupTreeNodeFeedStream do
  before{
    @user1 = FactoryGirl.create :user
    @feed1 = FactoryGirl.create :feed, :who => @user1
    @feed2 = FactoryGirl.create :feed, :who => @user1

    @user2 = FactoryGirl.create :user
    @feed3 = FactoryGirl.create :feed, :who => @user2
    @feed4 = FactoryGirl.create :feed, :who => @user2

    @user3 = FactoryGirl.create :user
    @feed5 = FactoryGirl.create :feed, :who => @user3
    @feed6 = FactoryGirl.create :feed, :who => @user3

    @user4 = FactoryGirl.create :user
    @feed7 = FactoryGirl.create :feed, :who => @user4
    @feed8 = FactoryGirl.create :feed, :who => @user4

    @group_tree_node1 = FactoryGirl.create :group_tree_node
    @group_tree_node1.add_user @user1
    @group_tree_node1.add_user @user2

    @group_tree_node2 = FactoryGirl.create :group_tree_node
    @group_tree_node2.add_user @user3
    @group_tree_node2.add_user @user4    
  }

  it{
    @group_tree_node1.home_timeline.should =~ [@feed1, @feed2, @feed3, @feed4]

    @group_tree_node2.home_timeline.should =~ [@feed5, @feed6, @feed7, @feed8]
  }
end

