require "spec_helper"

describe User do
  before {
    @current_inhouse = R::INHOUSE
    @current_internet = R::INTERNET

    R::INHOUSE = true
    R::INTERNET = false
  }

  after {
    R::INHOUSE = @current_inhouse
    R::INTERNET = @current_internet
  }

  describe "import file" do
    it "should raise format error" do
      file = File.new 'spec/data/user_import_test_files/incorrect_excel.aaa'

      expect {
        User.import_excel_teacher file
      }.to raise_error(Exception)
    end


    context "import teacher excel files" do
      describe "import xls format" do
        before {
          file = File.new 'spec/data/user_import_test_files/user.xls'

          expect{
            User.import_excel file, :teacher
          }.to change{User.count}.by(3)

          @user = User.find_by_name('hello2')
        }

        it {
          @user.login.should == 'aaa2'
        }

        it {
          @user.role?(:teacher).should == true
        }
      end

      describe "import xlsx format" do
        before {
          file = File.new 'spec/data/user_import_test_files/user.xlsx'

          expect{
            User.import_excel file, :teacher
          }.to change{User.count}.by(3)

          @user = User.find_by_name('hello2')
        }

        it {
          @user.login.should == 'aaa2'
        }

        it {
          @user.role?(:teacher).should == true
        }
      end

      it "import openoffice format" do
        file = File.new 'spec/data/user_import_test_files/user.sxc'
        
        expect{
          User.import_excel file, :teacher
        }.to change{User.count}.by(3)
      end
    end

    context "import student excel files" do
      it "import xls format" do
        file = File.new 'spec/data/user_import_test_files/user.xls'
       
        expect{
          User.import_excel file, :student
        }.to change{User.count}.by(3)
      end



      it "import xlsx format" do
        file = File.new 'spec/data/user_import_test_files/user.xlsx'

        expect{
          User.import_excel file, :student
        }.to change{User.count}.by(3)
      end

      it "import openoffice format" do
        file = File.new 'spec/data/user_import_test_files/user.sxc'
       
        expect{
          User.import_excel file, :student
        }.to change{User.count}.by(3)
      end
    end
  end
end