require 'spec_helper'

describe Attachment do
  before{
    @file_entity1 = FactoryGirl.create :file_entity, :attach_file_name => '1.jpg'
    @file_entity2 = FactoryGirl.create :file_entity, :attach_file_name => '2.jpg'
    @file_entity3 = FactoryGirl.create :file_entity, :attach_file_name => '2.jpg'
  }

  def test(model)
    model = model.class.find(model.id)
    model.file_entities.should == []

    model.file_entities = [@file_entity3]
    model = model.class.find(model.id)
    model.file_entities.should == [@file_entity3]

    model.file_entities = []
    model = model.class.find(model.id)
    model.file_entities.should == []

    model.file_entities = [@file_entity3, @file_entity1]
    model.file_entities << @file_entity2
    model = model.class.find(model.id)
    model.file_entities.should =~ [@file_entity2, @file_entity3, @file_entity1]
    
    model.file_entities.delete @file_entity1
    model = model.class.find(model.id)
    model.file_entities.should =~ [@file_entity2, @file_entity3]
  end

  it{
    question = FactoryGirl.create(:question)
    test(question)
  }

  it{
    question = FactoryGirl.create(:question)
    creator = FactoryGirl.create :user
    answer  = FactoryGirl.create :answer, :question => question,
      :creator => creator
    test(answer)
  }

  it{
    course = FactoryGirl.create(:course)
    chapter = FactoryGirl.create(:chapter, :course => course)
    test(chapter)
  }

  
end