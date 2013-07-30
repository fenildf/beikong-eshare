class TeamMembership < ActiveRecord::Base
  attr_accessible :team,:user

  belongs_to :team
  belongs_to :user

  validates :team_id, :uniqueness => {:scope => :user_id}

  validates :team, :user, :presence => true

  scope :by_user, lambda{|user| {:conditions => ['user_id = ?', user.id]} }

  module UserMethods
    def self.included(base)
      base.has_many :user_memberships, :class_name  => 'TeamMembership'
      base.has_many :joined_teams, :through => :user_memberships, :source=> :team
    end
  end

  module TeamMethods
    def self.included(base)
      base.has_many :team_memberships
      base.has_many :members, :through => :team_memberships, :source=> :user
    end

    # 2.增加 team 参与者
    def add_member(user)
      self.team_memberships.create(:user => user)
    end

    # 3.移除 team 参与者
    def remove_member(user)
      self.team_memberships.by_user(user).destroy_all
    end
    
  end


end