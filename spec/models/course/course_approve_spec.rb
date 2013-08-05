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
      @course.approve_status.should == 'WAITING'
    }

    it{
      Course.approve_status_with_waiting.should == [@course]
    }

    context '设置为 OK' do
      before{
        @course.update_attributes(:approve_status => 'YES')
        @course.reload
      }

      it{
        @course.approve_status.should == 'YES'
      }

      it{
        Course.approve_status_with_yes.should == [@course]
      }
    end

    context '设置为 NO' do
      before{
        @course.update_attributes(:approve_status => 'NO')
        @course.reload
      }

      it{
        @course.approve_status.should == 'NO'
      }

      it{
        Course.approve_status_with_no.should == [@course]
      }
    end
  end

  context 'scope' do
    before {
      1.times { FactoryGirl.create(:course, :approve_status => 'WAITING') }
      2.times { FactoryGirl.create(:course, :approve_status => 'YES') }
      3.times { FactoryGirl.create(:course, :approve_status => 'NO') }
    }

    it {
      Course.approve_status_with_waiting.count.should == 1
    }

    it {
      Course.approve_status_with_yes.count.should == 2
    }

    it {
      Course.approve_status_with_no.count.should == 3
    }

  end

end