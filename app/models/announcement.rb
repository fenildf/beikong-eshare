# -*- coding: utf-8 -*-
class Announcement < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  belongs_to :hostable, :polymorphic => true

  validates :title, :content, :creator_id, :on_top, :hostable, :presence => true
  
  module UserMethods
    def self.included(base)
      base.has_many :announcements, :foreign_key => 'creator_id'
    end
  end

  module HostableMethods
    def self.included(base)
      base.has_many :announcements, :as => :hostable
    end
  end

end
