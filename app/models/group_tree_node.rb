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
    self.group_tree_node_users.create(:user => user)
  end

  def remove_user(user)
    self.group_tree_node_users.find_by_user_id(user.id).destroy()
  end

  module UserMethods
    def self.included(base)
      base.has_many :group_tree_nodes
    end
  end
end