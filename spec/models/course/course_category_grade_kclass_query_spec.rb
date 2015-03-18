# require "spec_helper"

# describe Course do
#   describe ".by_category_grade_kclass(category, grade, kclass)" do
#     let(:category) {FactoryGirl.create :category}
#     let(:creator) {FactoryGirl.create :user, :teacher}
#     let(:course) {
#       FactoryGirl.create(:course,
#                          :category_id => category.id,
#                          :creator_id  => creator.id)
#     }
#     let(:grade) {
#       FactoryGirl.create(:group_tree_node,
#                          :name => "grade",
#                          :group_kind => GroupTreeNode::GROUP_KIND::GRADE,
#                          :kind => GroupTreeNode::STUDENT,
#                          :year => "2014",
#                          :grade_kind => GroupTreeNode::GRADE_KIND::SENIOR)
#     }
#     let(:kclass) {
#       FactoryGirl.create(:group_tree_node,
#                          :name => "kclass",
#                          :year => "2014",
#                          :group_kind => GroupTreeNode::GROUP_KIND::KCLASS,
#                          :kind => GroupTreeNode::STUDENT,
#                          :manage_user_id => creator.id)
#     }

#     before {kclass.move_to_child_of(grade)}

#     subject {Course.by_category_grade_kclass(category, grade, kclass)}

#     its(:first) {should eq course}
#   end
# end
