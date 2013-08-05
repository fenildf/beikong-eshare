R::SELECT_COURSE_MODE = 'ONE'
require "spec_helper"

describe OneCourseIntent do
  before{
    @teacher = FactoryGirl.create :user, :role => :teacher

    @course_1 = FactoryGirl.create :course, :approve_status => Course::APPROVE_STATUS_YES,
      :least_user_count => 2, :most_user_count => 3, :credit => 5
    @course_2 = FactoryGirl.create :course, :approve_status => Course::APPROVE_STATUS_YES,
      :least_user_count => 2, :most_user_count => 3, :credit => 5
    @course_3 = FactoryGirl.create :course, :approve_status => Course::APPROVE_STATUS_YES,
      :least_user_count => 2, :most_user_count => 3, :credit => 5
    @course_4 = FactoryGirl.create :course, :approve_status => Course::APPROVE_STATUS_YES,
      :least_user_count => 2, :most_user_count => 3, :credit => 5


    @team_1 = FactoryGirl.create :team
    @team_2 = FactoryGirl.create :team

    @user_1 = FactoryGirl.create :user, :role => :student
    @user_2 = FactoryGirl.create :user, :role => :student
    @user_3 = FactoryGirl.create :user, :role => :student
    @user_4 = FactoryGirl.create :user, :role => :student
    @user_5 = FactoryGirl.create :user, :role => :student
    @user_6 = FactoryGirl.create :user, :role => :student

    @team_1.add_member(@user_1)
    @team_1.add_member(@user_2)
    @team_1.add_member(@user_3)

    @team_2.add_member(@user_4)
    @team_2.add_member(@user_5)
    @team_2.add_member(@user_6)
  }

  it{
    @course_1.intent_users(:team => @team_1).should == []
    @course_1.intent_users.should == []
  }

  it{
    @course_1.intent_users_count(:team => @team_1).should == 0
    @course_1.intent_users_count.should == 0
  }

  it{
    @course_1.selected_users.should == []
  }

  it{
    @course_1.selected_users.count.should == 0
  }

  it{
    CourseIntent.need_adjust_users.should =~ [
      @user_1, @user_2, @user_3,
      @user_4, @user_5, @user_6
    ]
  }

  it{
    @course_1.select_status_of_user(@user_1).should == "未申请"
  }

  it{
    @course_1.intent_status.should == "无人申请"
  }

  context 'user_1 add course_intent' do
    before{
      Timecop.travel(Time.now + 1.second) do
        @user_1.add_course_intent(@course_1)
      end
    }

    it{
      @course_1.intent_users(:team => @team_1).should == [@user_1]
      @course_1.intent_users(:team => @team_2).should == []
      @course_1.intent_users.should == [@user_1]
    }

    it{
      @course_1.intent_users_count(:team => @team_1).should == 1
      @course_1.intent_users_count(:team => @team_2).should == 0
      @course_1.intent_users_count.should == 1
    }

    it{
      CourseIntent.need_adjust_users.should =~ [
        @user_1, @user_2, @user_3,
        @user_4, @user_5, @user_6
      ]
    }

    it{
      @course_1.select_status_of_user(@user_1).should == "等待志愿分配"
    }

    it{
      @course_1.intent_status.should == "人数过少"
    }

    context 'user_2 add course_intent' do
      before{
        Timecop.travel(Time.now + 2.second) do
          @user_2.add_course_intent(@course_1)
        end
      }

      it{
        @course_1.intent_users(:team => @team_1).should =~ [@user_1, @user_2]
        @course_1.intent_users(:team => @team_2).should == []
        @course_1.intent_users.should =~ [@user_1, @user_2]
      }

      it{
        @course_1.intent_users_count(:team => @team_1).should == 2
        @course_1.intent_users_count(:team => @team_2).should == 0
        @course_1.intent_users_count.should == 2
      }

      it{
        @course_1.intent_status.should == "人数适合"
      }

      context 'user_3 user_4 add course_intent' do
        before{
          Timecop.travel(Time.now + 3.second) do
            @user_3.add_course_intent(@course_1)
          end
          Timecop.travel(Time.now + 4.second) do
            @user_4.add_course_intent(@course_1)
          end
        }

        it{
          @course_1.intent_users(:team => @team_1).should =~ [@user_1, @user_2, @user_3]
          @course_1.intent_users(:team => @team_2).should == []
          @course_1.intent_users.should =~ [@user_1, @user_2, @user_3]
        }

        it{
          @course_1.intent_users_count(:team => @team_1).should == 3
          @course_1.intent_users_count(:team => @team_2).should == 0
          @course_1.intent_users_count.should == 3
        }

        it{
          @course_1.intent_status.should == "人数过多"
        }

        context '批处理  @course_1' do
          before{
            @course_1.batch_check
          }

          it{
            @course_1.selected_users.should == [@user_1, @user_2, @user_3]
          }

          it{
            @course_1.select_status_of_user(@user_1).should == "选中"
            @course_1.select_status_of_user(@user_2).should == "选中"
            @course_1.select_status_of_user(@user_3).should == "选中"
            @course_1.select_status_of_user(@user_4).should == "未选中"
          }

          context 'user_2 user_3 add course' do
            before{
              Timecop.travel(Time.now + 1.second) do
                @user_2.add_course_intent(@course_2)
              end
              Timecop.travel(Time.now + 1.second) do
                @user_3.add_course_intent(@course_2)
              end
              @course_2.batch_check
            }

            it{
              CourseIntent.need_adjust_users.should == [
                @user_1, @user_4,
                @user_5, @user_6
              ]
            }
          end
        end
      end
    end
  end
end