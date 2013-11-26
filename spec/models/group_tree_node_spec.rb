require "spec_helper"
describe GroupTreeNode do
  let(:user)  {FactoryGirl.create :user}
  let(:user1) {FactoryGirl.create :user}
  let(:user2) {FactoryGirl.create :user}
  
  before{
    @name_1 = '张三'
    @name_2 = "李四"

    @group_tree_node = GroupTreeNode.create(
                          :name => @name_1,
                          :kind => GroupTreeNode::TEACHER,
                          :parent_id => nil,
                          :manage_user => user
                        )
    @group_tree_node1 = GroupTreeNode.create(
                          :name => @name_2,
                          :kind => GroupTreeNode::TEACHER,
                          :manage_user => user
                        ).move_to_child_of(@group_tree_node)
    @group_tree_node2 = GroupTreeNode.create(
                          :name => @name_1,
                          :kind => GroupTreeNode::TEACHER,
                          :manage_user => user
                        ).move_to_child_of(@group_tree_node1)

    p "AAAA " + @group_tree_node.self_and_descendants.count.to_s
    p "BBBB " + @group_tree_node2.self_and_ancestors.count.to_s
  }

  describe '创建 group_tree_node' do
    it '创建 成功' do
      expect{
        GroupTreeNode.create(
          :name => @name_1,
          :kind => GroupTreeNode::TEACHER,
          :parent_id => nil,
          :manage_user => user
        )
      }.to change{GroupTreeNode.count}.by(1)
    end

    it '创建 成功' do
      group_tree_node = GroupTreeNode.create(
                          :name => @name_1,
                          :kind => GroupTreeNode::TEACHER,
                          :parent_id => nil,
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
    it '给子节点增加user 1' do
      @group_tree_node2.add_user(user1)
      @group_tree_node1.group_tree_node_users.find_by_user_id(user1.id).blank?.should == false
      @group_tree_node.group_tree_node_users.find_by_user_id(user1.id).blank?.should == false
    end

    it '给子节点增加user 2' do
      @group_tree_node1.add_user(user1)
      @group_tree_node.group_tree_node_users.find_by_user_id(user1.id).blank?.should == false
    end

  end

  describe '#remove_user(user)' do
    before{
      @group_tree_node2.add_user(user2)
    }

    it '移除父节点User' do
      @group_tree_node.remove_user(user2)

      @group_tree_node1.group_tree_node_users.find_by_user_id(user2.id).blank?.should == true
      @group_tree_node2.group_tree_node_users.find_by_user_id(user2.id).blank?.should == true
    end
  end
end