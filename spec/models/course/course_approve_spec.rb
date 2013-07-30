require 'spec_helper'

describe Course do
  context 'create' do
    before{
      @course = Course.create!(
        :name => 'xxx', :cid => randstr, 
        :creator => FactoryGirl.create(:user)
      )
    }

    it{
      @course.is_approved?.should == false
    }
  end

  context 'scope' do
    before {
      2.times { FactoryGirl.create(:course, :is_approved => true) }
      3.times { FactoryGirl.create(:course, :is_approved => false) }
    }

    it "approved count" do
      Course.approved.count.should == 2
    end

    it "not approved count" do
      Course.disapproved.count.should ==3
    end
  end

end