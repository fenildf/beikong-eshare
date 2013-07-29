class Team < ActiveRecord::Base
  attr_accessible :teacher_user,:name

  belongs_to :teacher_user,
             :class_name  => 'User',
             :foreign_key => :teacher_user_id

  validates :name,    :presence => true
  validates :teacher_user, :presence => true

  module UserMethods
    def self.included(base)
      base.has_many :teams, :foreign_key => :teacher_user_id
      base.has_many :manage_teams, :class_name => 'Team', :foreign_key => :teacher_user_id
    end

    # 1.user.teams.create(:name => xxxx)
    # 4.查询用户创建的 created_teams

  end

  include TeamMembership::TeamMethods
end