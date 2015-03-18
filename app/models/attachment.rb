class Attachment < ActiveRecord::Base
  attr_accessible :file_entity

  belongs_to :file_entity
  belongs_to :model, :polymorphic => true

  module ModelMethods
    def self.included(base)
      base.attr_accessible :file_entities
      base.has_many :attachments, :as => :model
      base.has_many :file_entities, :through => :attachments
    end
  end
end
