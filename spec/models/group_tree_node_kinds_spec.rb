# require "spec_helper"

# describe GroupTreeNode do
#   let(:node) do
#     FactoryGirl.build :group_tree_node,
#                       :name => "node",
#                       :kind => GroupTreeNode::STUDENT
#   end

#   context "group_kind == GROUP_KIND::OTHER" do
#     before do
#       node.group_kind = GroupTreeNode::GROUP_KIND::OTHER
#       node.valid?
#     end

#     let(:op1) {node.year = "2014";node.valid?}
#     let(:op2) {node.grade_kind = "bla";node.valid?}

#     specify {node.errors.should be_blank}
#     specify {op1;node.errors[:base][0].should include "OTHER"}
#     specify {op2;node.errors[:base][0].should include "OTHER"}
#     specify {op1;op2;node.errors[:base][0].should include "OTHER"}
#   end

#   context "group_kind == GROUP::KIND::GRADE" do
#     before do
#       node.group_kind = GroupTreeNode::GROUP_KIND::GRADE
#       node.grade_kind = GroupTreeNode::GRADE_KIND::SENIOR
#       node.year = "2014"
#       node.valid?
#     end

#     let(:op1) {node.year = nil;node.valid?}
#     let(:op2) {node.grade_kind = "bla";node.valid?}

#     specify {node.errors.should be_blank}
#     specify {op1;node.errors[:base][0].should include "GRADE"}
#     specify {op2;node.errors[:base][0].should include "GRADE"}
#     specify {op1;op2;node.errors[:base][0].should include "GRADE"}
#   end

#   context "group_kind == GROUP::KIND::KCLASS" do
#     let(:parent) do
#       FactoryGirl.create :group_tree_node,
#                          :name => "parent",
#                          :kind => GroupTreeNode::STUDENT,
#                          :year => "2014",
#                          :group_kind => GroupTreeNode::GROUP_KIND::GRADE,
#                          :grade_kind => GroupTreeNode::GRADE_KIND::SENIOR
#     end

#     let(:user) {FactoryGirl.create :user, :teacher}

#     let(:node1) do
#       FactoryGirl.create :group_tree_node,
#                          :name => "node1",
#                          :year => "2014",
#                          :group_kind => GroupTreeNode::GROUP_KIND::KCLASS,
#                          :kind => GroupTreeNode::STUDENT,
#                          :manage_user_id => user.id
#     end

#     before do
#       node.group_kind = GroupTreeNode::GROUP_KIND::KCLASS
#       node.year = node1.year
#       node.valid?
#     end

#     let(:op1) {node.save;node.move_to_child_of(parent)}
#     let(:op2) {node.grade_kind = "bla";node.valid?}
#     let(:op3) {node.manage_user = node1.manage_user;node.save;}

#     specify {node.errors.should be_blank}
#     specify {op1;node.year.should eq "2014"}
#     specify {node.should be_valid}
#     specify {op3;node.should be_invalid}
#     specify {op2;node.errors[:base][0].should include "KCLASS"}
#   end
# end
