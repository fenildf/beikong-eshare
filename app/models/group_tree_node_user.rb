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
      base.has_many :joined_group_tree_nodes,
        :through => :group_tree_node_users,
        :source  => :group_tree_node
      base.scope :without_group, base.joins(
        %`
          left join 
            group_tree_node_users
          on
            group_tree_node_users.user_id = users.id
        `
      ).where(%`
        group_tree_node_users.user_id is null
      `
      )
      base.scope :with_group, base.joins(%`
        INNER JOIN
          group_tree_node_users
        ON
          group_tree_node_users.user_id = users.id
      `).group('users.id')

      base.scope :with_student_group, base.joins(%`
        INNER JOIN
          group_tree_node_users
        ON
          group_tree_node_users.user_id = users.id
      `).joins(%`
        INNER JOIN
          group_tree_nodes
        ON
          group_tree_node_users.group_tree_node_id = group_tree_nodes.id
      `).where("group_tree_nodes.kind = '#{GroupTreeNode::STUDENT}'").group('users.id')

      base.scope :with_teacher_group, base.joins(%`
        INNER JOIN
          group_tree_node_users
        ON
          group_tree_node_users.user_id = users.id
      `).joins(%`
        INNER JOIN
          group_tree_nodes
        ON
          group_tree_node_users.group_tree_node_id = group_tree_nodes.id
      `).where("group_tree_nodes.kind = '#{GroupTreeNode::TEACHER}'").group('users.id')
    end

  end
end