class GroupTreeNodeUser < ActiveRecord::Base
  attr_accessible :user, :group_tree_node

  belongs_to :user
  belongs_to :group_tree_node

  validates :user,            :presence => true
  validates :group_tree_node, :presence => true

  validates  :group_tree_node_id,  :uniqueness => {:scope => :user_id}

  module UserMethods
    def self.included(base)
      base.has_many :group_tree_node_users
    end
  end
end