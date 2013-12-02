require 'spec_helper'

describe "gender" do
  describe "创建没有性别的学生" do
    before{
      @student1 = User.create(
        :login    => 'student1',
        :name     => 'student1',
        :password => '1234',
        :role     => :student)
    }

    it{
      @student1.id.blank?.should == false
      @student1.gender.blank?.should == true
    }

    it '设置学生性别为女' do
      @student1.gender = '女'
      @student1.save
      @student1 = User.find(@student1.id)
      @student1.gender.should == '女'
    end

    it '设置学生性别为男' do
      @student1.gender = '男'
      @student1.save
      @student1 = User.find(@student1.id)
      @student1.gender.should == '男'
    end
  end

  describe "创建没有性别的教师" do
    before{
      @teacher1 = User.create(
        :login    => 'teacher1',
        :name     => 'teacher1',
        :password => '1234',
        :role     => :teacher)
    }

    it{
      @teacher1.id.blank?.should == false
      @teacher1.gender.blank?.should == true
    }

    it '设置教师性别为女' do
      @teacher1.gender = '女'
      @teacher1.save
      @teacher1 = User.find(@teacher1.id)
      @teacher1.gender.should == '女'
    end

    it '设置教师性别为男' do
      @teacher1.gender = '男'
      @teacher1.save
      @teacher1 = User.find(@teacher1.id)
      @teacher1.gender.should == '男'
    end

    it '设置教师性别为秀吉' do
      @teacher1.gender = '秀吉'
      @teacher1.save
      @teacher1 = User.find(@teacher1.id)
      @teacher1.gender.should == ''
    end

    it "设置教师性别为男,在设置为空" do
      @teacher1.gender = '男'
      @teacher1.save
      @teacher1 = User.find(@teacher1.id)
      @teacher1.gender.should == '男'

      @teacher1.gender = ''
      @teacher1.save
      @teacher1 = User.find(@teacher1.id)
      @teacher1.gender.should == ''
    end
  end

  describe "创建有性别的教师" do
    before{
      @teacher1 = User.create(
        :login    => 'teacher1',
        :name     => 'teacher1',
        :password => '1234',
        :gender   => '男',
        :role     => :teacher)
    }

    it{
      @teacher1.gender.should == '男'
    }
  end

end