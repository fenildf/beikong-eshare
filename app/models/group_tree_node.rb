class GroupTreeNode < ActiveRecord::Base
  acts_as_nested_set

  TEACHER = "TEACHER"
  STUDENT = "STUDENT"

  attr_accessible :kind, :name, :parent, :manage_user

  belongs_to :manage_user, :class_name => 'User', :foreign_key => :manage_user_id 

  validates :kind, :presence => true, :inclusion=> [TEACHER,STUDENT]
  validates :name, :presence => true

  has_many :group_tree_node_users
  has_many :users, :through => :group_tree_node_users

  scope :with_teacher, :conditions => ["kind = ?", TEACHER]
  scope :with_student, :conditions => ["kind = ?", STUDENT]

  def add_user(user)
    self.self_and_ancestors.each do |node|
      node.group_tree_node_users.create(:user => user)
    end
  end

  def remove_user(user)
    self.self_and_descendants.each do |node|
      node.group_tree_node_users.find_by_user_id(user.id).destroy()
    end
  end

  def destroy
    return if self.children.count != 0 || self.users.count != 0
    super
  end

  module UserMethods
    def self.included(base)
      base.has_many :manage_group_tree_nodes,
        :class_name  => :GroupTreeNode,
        :foreign_key => :manage_user_id 
    end
  end
end