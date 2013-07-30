require "spec_helper"

describe SelectCourse do
  let(:user){FactoryGirl.create(:user)}
  let(:user1){FactoryGirl.create(:user)}
  let(:user2){FactoryGirl.create(:user)}
  let(:user3){FactoryGirl.create(:user)}
  let(:course){FactoryGirl.create :course, :apply_request_limit => 4}
  let(:course1){FactoryGirl.create(:course)}

  describe '#select_course(course) 选中 course 这门课程' do
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
  end

  describe '#cancel_select_course(course) 用户取消选择 course 这门课' do
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