FactoryGirl.define do
  factory :group_tree_node do
    sequence(:name){|n| "name_#{n}" }
    kind           {GroupTreeNode::TEACHER}
    group_kind     {GroupTreeNode::GROUP_KIND::OTHER}
    parent         {}
    manage_user    {FactoryGirl.create :user}
  end
end
