require "spec_helper"
describe GroupTreeNode do
  let(:user)  {FactoryGirl.create :user}
  let(:user1) {FactoryGirl.create :user}
  let(:user2) {FactoryGirl.create :user}
  
  before{
    @name_1 = '张三'
    @name_2 = "李四"
    @parent_nil = 0
  }
  describe '创建 group_tree_node' do
    it '创建 成功' do
      expect{
        GroupTreeNode.create(
          :name => @name_1,
          :kind => GroupTreeNode::TEACHER,
          :parent_id => @parent_nil,
          :manage_user => user
        )
      }.to change{GroupTreeNode.count}.by(1)
    end

    it '创建 成功' do
      group_tree_node = GroupTreeNode.create(
                          :name => @name_1,
                          :kind => GroupTreeNode::TEACHER,
                          :parent_id => @parent_nil,
                          :manage_user => user
                        )
      expect{
        GroupTreeNode.create(
          :name => @name_2,
          :kind => GroupTreeNode::TEACHER,
          :parent_id => group_tree_node.id,
          :manage_user => user
        )
      }.to change{GroupTreeNode.count}.by(1)
    end

  end

  describe '#add_user(user)' do
    before{
      @group_tree_node = GroupTreeNode.create(
                            :name => @name_1,
                            :kind => GroupTreeNode::TEACHER,
                            :parent_id => @parent_nil,
                            :manage_user => user
                          )
    }

    it '添加2个用户' do
      expect{
        @group_tree_node.add_user(user1)
        @group_tree_node.add_user(user2)
      }.to change{@group_tree_node.group_tree_node_users.count}.by(2)
    end

    it '添加1个用户' do
      expect{
        @group_tree_node.add_user(user1)
        @group_tree_node.add_user(user1)
      }.to change{@group_tree_node.group_tree_node_users.count}.by(1)
    end
  end

  describe '#remove_user(user)' do
    before{
      @group_tree_node = GroupTreeNode.create(
                            :name => @name_1,
                            :kind => GroupTreeNode::TEACHER,
                            :parent_id => @parent_nil,
                            :manage_user => user
                          )
      @group_tree_node.add_user(user1)
      @group_tree_node.add_user(user2)
    }

    it '移除2个用户' do
      expect{
        @group_tree_node.remove_user(user1)
        @group_tree_node.remove_user(user2)
      }.to change{@group_tree_node.group_tree_node_users.count}.by(-2)
    end

    it '移除1个用户' do
      expect{
        @group_tree_node.remove_user(user1)
      }.to change{@group_tree_node.group_tree_node_users.count}.by(-1)
    end
  end
end