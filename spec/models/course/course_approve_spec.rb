require 'spec_helper'

describe Course do

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