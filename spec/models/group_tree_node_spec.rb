# -*- coding: utf-8 -*-
require "spec_helper"
describe GroupTreeNode do
  before{
    @user = FactoryGirl.create :user
    @user1 = FactoryGirl.create :user
    @user2 = FactoryGirl.create :user

    @name_1 = '张三'
    @name_2 = "李四"

    @group_tree_node = GroupTreeNode.create(
                          :name => @name_1,
                          # :group_kind => GroupTreeNode::GROUP_KIND::OTHER,
                          :kind => GroupTreeNode::TEACHER,
                          :manage_user => @user
                        )
    @group_tree_node1 = GroupTreeNode.create(
                          :name => @name_2,
                          # :group_kind => GroupTreeNode::GROUP_KIND::OTHER,
                          :kind => GroupTreeNode::TEACHER,
                          :manage_user => @user
                        ).move_to_child_of(@group_tree_node)
    @group_tree_node2 = GroupTreeNode.create(
                          :name => @name_1,
                          # :group_kind => GroupTreeNode::GROUP_KIND::OTHER,
                          :kind => GroupTreeNode::TEACHER,
                          :manage_user => @user
                        ).move_to_child_of(@group_tree_node1)

  }

  it{
    @group_tree_node.parent.should == nil
  }

  it {
    @group_tree_node2.destroy
    GroupTreeNode.find_by_id(@group_tree_node2.id).blank?.should == true
  }

  it '删除有子组的群组失败' do
    @group_tree_node.destroy
    GroupTreeNode.find_by_id(@group_tree_node.id).blank?.should == false
  end

  it '删除有人的群组失败' do
    @group_tree_node2.add_user(@user1)
    @group_tree_node2.reload
    @group_tree_node2.destroy
    GroupTreeNode.find_by_id(@group_tree_node2.id).blank?.should == false
  end

  it "找到还没有在任何分组的人" do
    User.without_group.should =~ [@user1, @user2, @user]
    @group_tree_node.add_user(@user)
    User.without_group.should =~ [@user1, @user2]
  end

  it "找到还没有在任何分组的人" do
    User.with_group.should == []
    @group_tree_node.add_user(@user)
    User.with_group.should =~ [@user]
    User.with_student_group.should =~ []
    User.with_teacher_group.should =~ [@user]
  end

  it "用户加入的分组" do
    @user.joined_group_tree_nodes.should == []
    @group_tree_node.add_user(@user)
    @user.reload
    @user.joined_group_tree_nodes.should == [@group_tree_node]
    @group_tree_node2.add_user(@user)
    @user.reload
    @user.joined_group_tree_nodes.should =~ [@group_tree_node2,@group_tree_node]
  end

  it "change_nest_members" do
    @group_tree_node2.change_nest_members([@user2])
    @group_tree_node2.reload
    @group_tree_node2.users.should =~ [@user2]
    @group_tree_node2.change_nest_members([@user2, @user])
    @group_tree_node2.reload
    @group_tree_node2.users.should =~ [@user2, @user]
    @group_tree_node2.change_nest_members([@user1])
    @group_tree_node2.reload
    @group_tree_node2.users.should =~ [@user1]
  end

  describe '创建 group_tree_node' do
    it '创建 成功' do
      expect{
        GroupTreeNode.create(
          :name => @name_1,
          # :group_kind => GroupTreeNode::GROUP_KIND::OTHER,
          :kind => GroupTreeNode::TEACHER,
          :manage_user => @user
        )
      }.to change{GroupTreeNode.count}.by(1)
    end

    it '创建 成功' do
      group_tree_node = GroupTreeNode.create(
                          :name => @name_1,
                          # :group_kind => GroupTreeNode::GROUP_KIND::OTHER,
                          :kind => GroupTreeNode::TEACHER,
                          :manage_user => @user
                        )
      expect{
        GroupTreeNode.create(
          :name => @name_2,
          # :group_kind => GroupTreeNode::GROUP_KIND::OTHER,
          :kind => GroupTreeNode::TEACHER,
          :parent => group_tree_node,
          :manage_user => @user
        )
      }.to change{GroupTreeNode.count}.by(1)
    end

  end

  describe '#add_user(user)' do
    it '给子节点增加user 1' do
      @group_tree_node2.add_user(@user1)

      @group_tree_node2.reload
      @group_tree_node1.reload
      @group_tree_node.reload

      @group_tree_node2.direct_members.include?(@user1).should == true
      @group_tree_node1.direct_members.include?(@user1).should == false
      @group_tree_node.direct_members.include?(@user1).should == false

      @group_tree_node2.nest_members.include?(@user1).should == true
      @group_tree_node1.nest_members.include?(@user1).should == true
      @group_tree_node.nest_members.include?(@user1).should == true
    end

    it '给子节点增加user 2' do
      @group_tree_node1.add_user(@user1)
      
      @group_tree_node2.reload
      @group_tree_node1.reload
      @group_tree_node.reload

      @group_tree_node1.direct_members.include?(@user1).should == true
      @group_tree_node.direct_members.include?(@user1).should == false

      @group_tree_node1.nest_members.include?(@user1).should == true
      @group_tree_node.nest_members.include?(@user1).should == true
    end

  end

  describe '#remove_user(user)' do
    before{
      @group_tree_node2.add_user(@user2)
      @group_tree_node2.reload
      @group_tree_node1.reload
      @group_tree_node.reload
    }

    it{
      @group_tree_node2.direct_members.include?(@user2).should == true
    }

    it  do
      @group_tree_node2.remove_user(@user2)

      @group_tree_node2.reload
      @group_tree_node1.reload
      @group_tree_node.reload

      @group_tree_node2.direct_members.include?(@user2).should == false
      @group_tree_node1.nest_members.include?(@user2).should == false
      @group_tree_node.nest_members.include?(@user2).should == false
    end
  end

end
