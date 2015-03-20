require "spec_helper"

describe Course do

  describe '老师负责课程' do
    before {
      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
      @course = FactoryGirl.create(:course, :creator => @user_1)

      2.times {
        FactoryGirl.create(:course)
      }

      3.times {
        @course_for_user_2 = FactoryGirl.create(:course, :creator => @user_2)
      }

      @course_1 = FactoryGirl.create(:course)

      @course_1.add_teacher_user(@user_1)
    }

    it '数量正确' do
      @user_1.own_courses.count.should == 2
    end

    it '数量正确' do
      @user_2.own_courses.count.should == 3
    end

    it 'should be true' do
      @user_2.has_own_course?(@course_for_user_2).should == true
    end

    it 'should be false' do
      @user_1.has_own_course?(@course_for_user_2).should == false
    end

    it 'should be true' do
      @user_1.has_own_course?(@course_1).should == true
    end
  end
  
  context '签到模块' do
    before do
      @user   = FactoryGirl.create(:user)
      @course = FactoryGirl.create(:course)
    end

    describe '#sign' do
      it{expect {@course.sign(@user)}.to change {CourseSign.count}.by(1)}
    end

    describe '#current_streak_for' do
      context '昨天没有签到' do
        it {
          @course.current_streak_for(@user).should == 0
        }

        it {
          @course.sign(@user)
          @course.current_streak_for(@user).should == 1
        }
      end

      context '昨天有签到' do
        before do
          Timecop.travel(Time.now - 1.day) do
            @course.sign(@user)
          end
        end

        it {
          @course.course_signs.count.should == 1
        }

        it {
          @course.sign(@user)
          @course.current_streak_for(@user).should == 2
        }

        it {
          @course.sign(@user)
          @course.course_signs.count.should == 2
        }
      end

      context '昨天前天连续签到了' do
        before do
          p Time.zone.now

          Timecop.travel(Time.now - 2.day) do
            @course.sign(@user)
          end

          Timecop.travel(Time.now - 1.day) do
            @course.sign(@user)
          end
        end

        it {
          @course.current_streak_for(@user).should == 0
        }

        it {
          @course.sign(@user)
          @course.current_streak_for(@user).should == 3
        }
      end

      context '不能连续签到' do
        before {
          @course.sign(@user)
          @course.sign(@user)
          @course.sign(@user)
          @course.sign(@user)
        }

        it {
          @course.current_streak_for(@user).should == 1
        }

        it {
          @course.course_signs.count.should == 1
        }
      end
    end

    describe '#signs_count' do
      let(:user1) {FactoryGirl.create :user}
      let(:user2) {FactoryGirl.create :user}
      let(:user3) {FactoryGirl.create :user}
      let(:course2) {FactoryGirl.create :course}
      before do
        course2.sign(user1)
        @course.sign(user1)
        @course.sign(user2)
        @course.sign(user3)
      end
      it{ @course.signs_count.should == 3 }
      it{ course2.signs_count.should == 1 }
    end

    describe '#today_sign_order_of(user)' do
      let(:user1) {FactoryGirl.create :user}
      let(:user2) {FactoryGirl.create :user}
      let(:user3) {FactoryGirl.create :user}
      before do 
        @course.sign(user1)
        @course.sign(user2)
      end
      it { @course.today_sign_order_of(user1).should == 1 }
      it { @course.today_sign_order_of(user2).should == 2 }
      it { @course.today_sign_order_of(user3).should be_blank }
      it { @course.today_sign_order_of(FactoryGirl.create :user).should be_blank }
    end

    describe '#today_signs_count' do
      let(:user1) {FactoryGirl.create :user}
      let(:user2) {FactoryGirl.create :user}
      let(:user3) {FactoryGirl.create :user}
      let(:course2) {FactoryGirl.create :course}
      before do
        course2.sign(user1)
        @course.sign(user1)
        @course.sign(user2)
        @course.sign(user3)
      end
      it {@course.today_signs_count.should == 3}
      it {course2.today_signs_count.should == 1}
    end

    describe '两个不同的用户签到' do
      before {
        @user1 = FactoryGirl.create :user
        @user2 = FactoryGirl.create :user
        @course = FactoryGirl.create :course
        @course.sign @user1
        @course.sign @user2
      }

      it {
        @course.course_signs.count.should == 2
      }

      it {
        @course.today_sign_order_of(@user1).should == 1
      }

      it {
        @course.today_sign_order_of(@user2).should == 2
      }
    end
  end

  context '正在学习的课程 joined_courses' do
    before {
      @user = FactoryGirl.create :user
      @user1 = FactoryGirl.create :user

      5.times do
        course_ware = FactoryGirl.create :course_ware, :total_count => 100
      end

      CourseWare.all[0].update_read_count_of(@user, 20)
      CourseWare.all[1].update_read_count_of(@user, 30)
      CourseWare.all[3].update_read_count_of(@user, 50)

      CourseWare.all[2].update_read_count_of(@user1, 50)
      CourseWare.all[4].update_read_count_of(@user1, 60)
    }

    it {
      @user.joined_courses.should =~ [
        CourseWare.all[0].chapter.course, 
        CourseWare.all[1].chapter.course,
        CourseWare.all[3].chapter.course
      ]
    }

    it {
      @user1.joined_courses.should =~ [
        CourseWare.all[2].chapter.course, 
        CourseWare.all[4].chapter.course
      ]
    }
  end
end