class GroupTreeNode < ActiveRecord::Base
  acts_as_nested_set

  TEACHER = "TEACHER"
  STUDENT = "STUDENT"

  attr_accessible :kind, :name, :parent_id, :manage_user

  belongs_to :manage_user, :class_name => 'User', :foreign_key => :manage_user_id 

  belongs_to :parent, :class_name => "GroupTreeNode", :foreign_key => :parent_id

  validates :kind, :presence => true, :inclusion=> [TEACHER,STUDENT]
  validates :name, :presence => true
  validates :manage_user, :presence => true

  has_many :group_tree_node_users

  def add_user(user)
    # p "self_and_ancestors #{ self.self_and_ancestors.count}"
    self.self_and_ancestors.each do |node|
      node.group_tree_node_users.create(:user => user)
    end
  end

  def remove_user(user)
    # p "count #{ self.self_and_descendants.count}"
    self.self_and_descendants.each do |node|
      # p "node #{node.id}"
      node.group_tree_node_users.find_by_user_id(user.id).destroy()
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :group_tree_nodes
    end
  end
end