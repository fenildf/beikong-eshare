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
    self.group_tree_node_users.create(:user => user)
  end

  def remove_user(user)
    self.group_tree_node_users.find_by_user_id(user.id).destroy()
  end

  def destroy
    return if self.children.count != 0 || self.users.count != 0
    super
  end

  # 查询直接在这个分组里的人
  def direct_members
    self.users
  end

  # 查询在这个分组以及这个分组所有的下级分组里的人
  def nest_members
    User.nest_members_of(self)
  end

  module UserMethods
    def self.included(base)
      base.has_many :manage_group_tree_nodes,
        :class_name  => :GroupTreeNode,
        :foreign_key => :manage_user_id 

      base.scope :nest_members_of, lambda{ |group_tree_node|
        base.joins(
          %`
            INNER JOIN
              group_tree_node_users
            ON
              users.id = group_tree_node_users.user_id
          `
        ).joins(
          %`
          INNER JOIN
            group_tree_nodes
          ON
            group_tree_node_users.group_tree_node_id = group_tree_nodes.id
          `
        ).where(%`
          group_tree_nodes.lft >= #{group_tree_node.lft}
            AND 
          group_tree_nodes.rgt <= #{group_tree_node.rgt}
        `
        ).group("users.id")
      }
    end
  end
end