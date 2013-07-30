require "spec_helper"

describe SelectCourse do
  let(:user){FactoryGirl.create(:user)}
  let(:user1){FactoryGirl.create(:user)}
  let(:user2){FactoryGirl.create(:user)}
  let(:user3){FactoryGirl.create(:user)}
  let(:course){FactoryGirl.create :course, :apply_request_limit => 4}
  let(:course1){FactoryGirl.create(:course)}

  describe '#select_course(course) 7 用户发起一个选课请求' do
    it { 
      expect {
        user.select_course(course)
      }.to change {
        SelectCourse.all.count
      }.by(1) 
    }

    it { 
      expect {
        user.select_course(course)
        user.select_course(course)
      }.to change {
        SelectCourse.all.count
      }.by(1) 
    }

    context '#到达选课人数上限' do
      before do
        user.select_course(course)
        user1.select_course(course)
        user2.select_course(course)
        user3.select_course(course)
        @user4 = FactoryGirl.create(:user)
      end
      it { 
        expect {
          @user4.select_course(course)
        }.to change {
          SelectCourse.all.count
        }.by(1)  
      }
    end
  end

  describe '#cancel_select_course(course) 学生自己主动取消选择一门课程' do
    before{
      user.select_course(course)
    }

    it { 
      expect {
        user.cancel_select_course(course)
      }.to change {
        SelectCourse.all.count
      }.by(-1)
    }

    it { 
      expect {
        user.cancel_select_course(course1)
      }.to change {
        SelectCourse.all.count
      }.by(0)
    }

    it { 
      expect {
        user1.cancel_select_course(course)
      }.to change {
        SelectCourse.all.count
      }.by(0)
    }
  end
end