# -*- coding: utf-8 -*-
class GroupTreeNode < ActiveRecord::Base
  acts_as_nested_set

  module GROUP_KIND
    OTHER  = "OTHER"
    GRADE  = "GRADE"
    KCLASS = "KCLASS"

    def self.all
      [OTHER, GRADE, KCLASS]
    end
  end

  module GRADE_KIND
    OTHER  = "OTHER"
    SENIOR = "SENIOR"
    JUNIOR = "JUNIOR"

    def self.all
      [OTHER, SENIOR, JUNIOR]
    end
  end

  TEACHER = "TEACHER"
  STUDENT = "STUDENT"

  attr_accessible :kind, :name, :parent, :manage_user

  belongs_to :manage_user, :class_name => 'User', :foreign_key => :manage_user_id 

  validates :kind, :presence => true, :inclusion=> [TEACHER,STUDENT]
  validates :name, :presence => true

  validates :group_kind, :inclusion => {:in => GROUP_KIND.all}
  validates :group_kind, :uniqueness => {
    :scope => :manage_user_id,
    :if    => ->(node) {GROUP_KIND::KCLASS == node.group_kind}
  }

  validate do
    case group_kind
    when GROUP_KIND::OTHER
      invalid_grade_kind_and_year_for(GROUP_KIND::OTHER) do
        !grade_kind.blank? || !year.blank?
      end
    when GROUP_KIND::GRADE
      invalid_grade_kind_and_year_for(GROUP_KIND::GRADE) do
        !GRADE_KIND.all.include?(grade_kind) || year.blank?
      end
    when GROUP_KIND::KCLASS
      invalid_grade_kind_and_year_for(GROUP_KIND::KCLASS) do
        !grade_kind.blank?
      end
    end
  end

  after_move :set_year_to_parents

  has_many :group_tree_node_users
  has_many :users, :through => :group_tree_node_users

  scope :with_teacher, :conditions => ["kind = ?", TEACHER]
  scope :with_student, :conditions => ["kind = ?", STUDENT]

  def set_year_to_parents
    if parent && GROUP_KIND::GRADE == parent.group_kind &&
       GROUP_KIND::KCLASS == group_kind && grade_kind.blank?

      self.year = parent.year
    end
  end

  def invalid_grade_kind_and_year_for(group_kind, &cond)
    if instance_eval(&cond)
      errors.add(:base, "Invalid grade_kind and year combination with GROUP_KIND::#{group_kind}")
    end
  end

  def add_user(user)
    self.group_tree_node_users.create(:user => user)
  end

  def remove_user(user)
    self.group_tree_node_users.find_by_user_id(user.id).destroy()
  end

  def remove_nest_user(user)
    user.group_tree_node_users.joins(%`
      INNER JOIN 
        group_tree_nodes
      ON
        group_tree_nodes.id = group_tree_node_users.group_tree_node_id
    `).where(
      "group_tree_nodes.lft >= #{self.lft} AND group_tree_nodes.rgt <= #{self.rgt}"
    ).destroy_all
  end

  def change_nest_members(replace_users)
    current_users = self.nest_members

    # find add users
    add_users = replace_users - current_users
    add_users.each{|user|self.add_user(user)}
    # find remove users
    remove_users = current_users - replace_users
    remove_users.each{|user|self.remove_nest_user(user)}
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

      base.has_many :group_tree_nodes,
        :through => :group_tree_node_users

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
