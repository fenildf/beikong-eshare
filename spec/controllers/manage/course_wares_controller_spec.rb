require 'spec_helper'

describe Manage::CourseWaresController do
  before {
    @user = FactoryGirl.create :user
    sign_in @user

    @chapter = FactoryGirl.create :chapter
  }

  context '#move_up, #move_down' do
    before {
      8.times do
        FactoryGirl.create :course_ware, :chapter => @chapter
      end

      @pos = @chapter.course_wares.map(&:position)
    }

    it {
      put :move_up, :id => @chapter.course_wares.last.id
      @chapter.course_wares.unscoped.map(&:position).should_not == @pos
    }

    it {
      put :move_down, :id => @chapter.course_wares.last.id
      @chapter.course_wares.unscoped.map(&:position).should == @pos
    }

    it {
      put :move_up, :id => @chapter.course_wares.first.id
      @chapter.course_wares.unscoped.map(&:position).should == @pos
    }

    it {
      put :move_down, :id => @chapter.course_wares.first.id
      @chapter.course_wares.unscoped.map(&:position).should_not == @pos
    }
  end
end