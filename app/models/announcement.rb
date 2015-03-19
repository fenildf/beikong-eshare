# -*- coding: utf-8 -*-
class Announcement < ActiveRecord::Base
  attr_accessible :title, :content, :creator, :on_top, :host, :host_id, :host_type

  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  belongs_to :host, :polymorphic => true

  validates :title, :content, :presence => true


  scope :by_manager, :conditions => ['host_type = ?', 'System']
  
  module UserMethods
    def self.included(base)
      base.has_many :announcements, :foreign_key => 'creator_id'
    end
  end

  module HostableMethods
    def self.included(base)
      base.has_many :announcements, :as => :host
    end
  end

end
