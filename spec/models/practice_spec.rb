require 'spec_helper'

describe Practice do

  describe "创建习题" do

    before {
      @user = FactoryGirl.create(:user)

      @chapter = FactoryGirl.create(:chapter)
      @practice = FactoryGirl.create(:practice)
      @file_entity = FactoryGirl.create(:file_entity)
    }

    it "创建习题" do
      expect{
        @chapter.practices.create(
          :title => '标题', 
          :content => "内容", 
          :creator => @user
        )
      }.to change{Practice.count}.by(1)
    end

    it "创建习题附件" do
      expect{
        @practice.file_entities = [@file_entity]
      }.to change{Attachment.count}.by(1)
    end

    it "习题还未有任何提交" do
      @practice.created_records.count.should == 0
    end

    it "学生的习题提交状态" do
      @practice.in_submitted_status_of_user?(@user).should == false
    end

    describe "提交习题" do
      before {
        @time = Time.now

        Timecop.travel(@time) do
          @practice.submit_by_user(@user)
        end
      }

      it "学生不能重复提交习题" do
        expect{
          @practice.submit_by_user(@user)
        }.to change{PracticeRecord.count}.by(0)
      end


      it "学生的习题提交状态" do
        @practice.in_submitted_status_of_user?(@user).should == true
      end

      it "学生的习题被批阅状态" do
        @practice.in_checked_status_of_user?(@user).should == false
      end

      it "习题的提交时间" do
        @practice.get_record_by_user(@user).submitted_at.to_i.should == @time.to_i
      end

      it "习题的批阅时间" do
        @practice.get_record_by_user(@user).checked_at.blank?.should == true
      end

      it "习题是否是线下提交" do
        @practice.in_submitted_offline_of_user?(@user).should == false
      end


      describe '批阅习题' do
        before {
          @time = Time.now
          @score = 60
          @comment = 'test'

          Timecop.travel(@time) do
            @practice.check_by_user(@user, @score, @comment)
          end
          
        }

        it "已经被批阅" do
          @practice.in_checked_status_of_user?(@user).should == true
        end

        it "批阅时间正确" do
          @practice.get_record_by_user(@user).checked_at.to_i.should == @time.to_i
        end

        it "习题的评分" do
          @practice.get_record_by_user(@user).score.should == @score
        end

        it "习题的评语" do
          @practice.get_record_by_user(@user).comment.should == @comment
        end
      end


      describe "线下提交" do
        before {
          @submit_desc = 'test desc'
          @practice.submittd_offline_by_user(@user, @submit_desc)
        }

        it "已经在线下提交" do
          @practice.in_submitted_offline_of_user?(@user).should == true
        end

        it "submit_desc" do
          @practice.get_record_by_user(@user).submit_desc.should == @submit_desc
        end

      end
      
    end

  end

  describe "创建习题" do
    before {
      @user = FactoryGirl.create(:user)
      @chapter = FactoryGirl.create(:chapter)
      
      @practice = @chapter.practices.create(
        :title => '标题', 
        :content => '内容',
        :creator => @user
      )

    }

    it "practice 创建成功" do
      @practice.id.blank?.should == false
    end

    describe "习题提交物" do
      before {
       
        @file_entity_1 = FactoryGirl.create(:file_entity)
        @file_entity_2 = FactoryGirl.create(:file_entity)

        @practice.add_upload(@user, @file_entity_1)
        @practice.add_upload(@user, @file_entity_2)
      }

      it{
        @practice.uploads.by_creator(@user).first.file_entities.count.should == 2
      }
    end

  end


  describe "创建课程习题" do
    before {
      @user = FactoryGirl.create(:user)

      @course = FactoryGirl.create(:course)
      @practice = FactoryGirl.create(:practice, :creator => @user)
    }

    it "习题还未有任何提交" do
      @practice.created_records.count.should == 0
    end

    it "习题数量" do
      Practice.by_creator(@user).by_course(@course).count.should == 0
    end

    describe "在某个课程下创建习题" do
      before {
        @chapter = FactoryGirl.create(:chapter, :course => @course)
        @practice = FactoryGirl.create(:practice, :creator => @user, :chapter => @chapter)
      }

      it "习题数量" do
        Practice.by_creator(@user).by_course(@course).count.should == 1
      end
    end

    describe "学生提交习题" do
      before {
        @student1 = FactoryGirl.create(:user)
        @student2 = FactoryGirl.create(:user)
        @student3 = FactoryGirl.create(:user)

        @practice.submit_by_user(@student1)
        @practice.submit_by_user(@student2)
      }

      it "学生列表" do
        @practice.submitted_users.should =~ [@student1, @student2]
      end

      it "完成习题的学生列表" do
        @practice.checked_users.should == []
      end

      it "线下完成习题的学生列表" do
        @practice.submitted_offline_users.should == []
      end

      describe "老师批阅学生的习题" do
        before {
          @score = 60
          @comment = 'hello comment'
          @practice.check_by_user(@student1, @score, @comment)
        }

        it "完成作业的学生列表" do
          @practice.checked_users.should == [@student1]
        end

      end

    end

  end
  
end