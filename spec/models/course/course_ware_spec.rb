require 'spec_helper'

describe CourseWare do

  describe 'link file_entity' do
    before do
      @course_ware = FactoryGirl.create(:course_ware)
      @user = FactoryGirl.create(:user)

      @file_entity = FileEntity.create(
        :attach => File.new(Rails.root.join("spec/data/file_entity.jpg")))

    end

    it{
      @course_ware.file_entity.should == nil
    }

    describe 'set file_entity' do
      before do
        @course_ware.file_entity = @file_entity
        @course_ware.save
        @course_ware.reload
        @media_resource = MediaResource.last
      end

      it {
        @course_ware.file_entity.should == @file_entity  
      }

      it {
        @course_ware.kind.should == 'image'
      }

      it {
        MediaResource.last.file_entity.should == @file_entity
      }

      it {
        @course_ware.media_resource.should == @media_resource
      }

      it {
        @media_resource.destroy
        @course_ware.reload
        @course_ware.media_resource.should be_blank
      }

      describe 'update course_ware' do
        before{
          @course_ware.title = 'gai'
          @course_ware.save
          @course_ware.reload
        }

        it{
          @course_ware.media_resource.should == @media_resource
        }

        describe 'update file_entity' do
          before{
            @file_entity_1 = FileEntity.create(
              :attach => File.new(Rails.root.join("spec/data/file_entity.jpg")))

            @course_ware.file_entity = @file_entity_1
            @course_ware.save
            @course_ware.reload
          }

          it{
            @course_ware.media_resource.should_not == @media_resource
          }

          it{
            @course_ware.file_entity.should == @file_entity_1
          }

          it{
            @course_ware.media_resource.should == MediaResource.last
          }
        end
      end
    end

  end


  context '课程进度: 记录课件的已读状态' do
    before do
      @course_ware   = FactoryGirl.create(:course_ware, :total_count => nil)
      @course_ware1  = FactoryGirl.create(:course_ware, :total_count => 3)
      @user          = FactoryGirl.create(:user)
    end

    it {
      @course_ware.reload.total_count.should == 0
    }

    it {
      @course_ware1.reload.total_count.should == 3
    }

    it('设置为未读时，将 read_count 清零') {
      @course_ware.set_read_by!(@user)
      @course_ware.course_ware_readings.by_user(@user).first.read_count.should == 0
    }

    it('标记为已读'){
      expect {
        @course_ware.set_read_by!(@user)
      }.to change {
        @course_ware.readed_users_count
      }.by(1)
    }

    it('标记为未读') {
      @course_ware.set_read_by!(@user)
      
      expect { 
        @course_ware.set_unread_by!(@user)
      }.to change {
        @course_ware.readed_users_count
      }.by(-1)
    }
    
    describe 'read_count' do

      it('when set read_count < total_count') {
        expect {
          @course_ware1.update_read_count_of(@user, 1)
        }.to change {
          @course_ware1.readed_users_count
        }.by(0)
      }

      it('when set read_count = total_count') {
        expect {
          @course_ware1.update_read_count_of(@user, 3)
        }.to change {
          @course_ware1.readed_users_count
        }.by(1)
      }

      it('when set read_count > total_count') {
        expect {
          @course_ware1.update_read_count_of(@user, 4)
        }.to change {
          @course_ware1.readed_users_count
        }.by(0)
      }

      context '标记为未读' do
        before { @course_ware1.update_read_count_of(@user, 3) }

        it {
          @course_ware1.has_read?(@user).should == true
        }

        it {
          @course_ware1.set_unread_by!(@user)
          @course_ware1.has_read?(@user).should == false
        }

        it {
          expect {
            @course_ware1.set_unread_by!(@user)
          }.to change {
            @course_ware1.readed_users_count
          }.by(-1)
        }
      end

      context '校验 valid' do
        before {
          @reading = CourseWareReading.new :course_ware => @course_ware1, 
                                           :user        => @user, 
                                           :read        => false, 
                                           :read_count  => 3
        }

        it {
          @course_ware1.total_count.should == 3
        }

        it {
          @reading.read_count.should == 3
        }

        it('当 read_count == total_count 时，不能设置为未读') { 
          @reading.read = false
          @reading.valid?.should == false 
        }

        it {
          @reading.read = true
          @reading.valid?.should == true 
        }

        context '但是有特殊情况，当 total_count, read_count 都等于 0 时，可以设置为未读' do
          before {
            @course_ware2 = FactoryGirl.create :course_ware, :total_count => 0

            @reading = CourseWareReading.new :course_ware => @course_ware2, 
                                             :user        => @user, 
                                             :read        => false, 
                                             :read_count  => 0
          }

          it {
            @reading.valid?.should == true
          }

          it {
            @reading.read_count = 3
            @reading.valid?.should == false
          }
        end
      end
    end


    describe '#has_read?' do
      context '用户未读' do
        it    { @course_ware.has_read?(@user).should == false}
      end
      context '用户已经读' do
        before{ @course_ware.set_read_by!(@user) }
        it    { @course_ware.has_read?(@user).should == true}
      end
    end

    describe '#readed_users_count' do
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }
      let(:user3) { FactoryGirl.create(:user) }
      let(:user4) { FactoryGirl.create(:user) }
      let(:user5) { FactoryGirl.create(:user) }
      before do 
        @course_ware.set_read_by!(user1)
        @course_ware.set_read_by!(user2)
        @course_ware.set_read_by!(user3)
        @course_ware.set_read_by!(user4)
        @course_ware.set_read_by!(user5)
      end
      it    { @course_ware.readed_users_count.should == 5 }
    end
  end

  describe '本地视频' do
    before {
      @course_ware = FactoryGirl.create :course_ware, :kind => :flv
    }

    it {
      CourseWare.last.total_count.should == 1000
    }
  end

  describe 'by_course' do
    before{
      @course_1 = FactoryGirl.create(:course)
      @chapter_1_1 = FactoryGirl.create(:chapter, :course => @course_1)
      @course_ware_1_1_1 = FactoryGirl.create(:course_ware, :chapter => @chapter_1_1)
      @course_ware_1_1_2 = FactoryGirl.create(:course_ware, :chapter => @chapter_1_1)
      @chapter_1_2 = FactoryGirl.create(:chapter, :course => @course_1)
      @course_ware_1_2_1 = FactoryGirl.create(:course_ware, :chapter => @chapter_1_2)

      @course_2 = FactoryGirl.create(:course)
      @chapter_2_1 = FactoryGirl.create(:chapter, :course => @course_2)
      @course_ware_2_1 = FactoryGirl.create(:course_ware, :chapter => @chapter_2_1)
    }

    it{
      CourseWare.by_course(@course_1).should =~ [
        @course_ware_1_1_1,
        @course_ware_1_1_2,
        @course_ware_1_2_1
      ]
    }

    it{
      CourseWare.by_course(@course_2).should =~ [@course_ware_2_1]
    }
  end

  describe 'CourseWare.read_with_user(user)' do
    before{
      @course_ware_1 = FactoryGirl.create(:course_ware)
      @course_ware_2 = FactoryGirl.create(:course_ware)
      @course_ware_3 = FactoryGirl.create(:course_ware)
      @course_ware_4 = FactoryGirl.create(:course_ware)

      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
    }

    it{
      CourseWare.read_with_user(@user_1).should == []
    }

    it{
      CourseWare.read_with_user(@user_2).should == []
    }

    describe '分别进行阅读' do
      before{
        @course_ware_1.set_read_by!(@user_1)
        @course_ware_4.set_read_by!(@user_1)

        @course_ware_1.set_read_by!(@user_2)
        @course_ware_3.set_read_by!(@user_2)
      }

      it{
        CourseWare.read_with_user(@user_1).should =~ [
          @course_ware_1,
          @course_ware_4
        ]
      }

      it{
        CourseWare.read_with_user(@user_2).should =~ [
          @course_ware_1,
          @course_ware_3
        ]
      }
    end


  end


  context '#update_read_count_of(user)' do
    before {
      @course_ware = FactoryGirl.create :course_ware
      @user = FactoryGirl.create :user
    }

    it {
      @course_ware.update_read_count_of(@user, 5)
    }
  end

  describe '视频/ppt/pdf 的标注 CourseWareMarkModule' do
    before {
      @course_ware = FactoryGirl.create(:course_ware)
      @user = FactoryGirl.create(:user)
    }

    describe '#add_mark' do
      before {@position = 12}

      context 'content 内容为空' do
        it{
          expect { 
            @course_ware.add_mark(@user,@position,nil)
          }.to change {
            @course_ware.course_ware_marks.count
          }.by(0)
        }
      end

      context 'content 内容为不为空' do
        it{
          expect { 
            @course_ware.add_mark(@user,@position,'content 内容')
          }.to change {
            @course_ware.course_ware_marks.count
          }.by(1)
        }
      end
    end

    describe '#get_marks' do
      before {
        @position = 12
        @course_ware.add_mark(@user,@position,'content 内容 1')
        @course_ware.add_mark(@user,@position,'content 内容 2')
        @course_ware.add_mark(@user,@position,'content 内容 3')
      }

      it {
        @course_ware.get_marks(@position).size.should == 3
      }

      it {
        @course_ware.get_marks(@position).first.user.should == @user
      }

      it {
        @course_ware.get_marks(@position).first.position.should == @position
      }
    end
  end



  describe '上下移动' do
    before {
      @chapter = FactoryGirl.create(:chapter)
      3.times { FactoryGirl.create(:course_ware, :chapter => @chapter) }
      @course_wares = CourseWare.all

      @course_ware1 = @course_wares.first
      @course_ware2 = @course_wares.second
      @course_ware3 = @course_wares.last
    }

    it "最后上一个" do
      @course_ware3.prev.should == @course_ware2
    end

    it "中间上一个" do
      @course_ware2.prev.should == @course_ware1
    end

    it "第一个下一个" do
      @course_ware1.next.should == @course_ware2
    end

    it "中间下一个" do
      @course_ware2.next.should == @course_ware3
    end

    it "主键 id 跟 position 相等" do
      @course_ware1.id.should == @course_ware1.position
      @course_ware2.id.should == @course_ware2.position
      @course_ware3.id.should == @course_ware3.position
    end

    it "最后一个向上移动" do
      @course_ware3.move_up
      CourseWare.all.should == [
        @course_ware1,
        @course_ware3,
        @course_ware2
      ]
    end

    it "最后一个上下移动" do
      @course_ware3.move_up.move_down
      CourseWare.all.should == [
        @course_ware1,
        @course_ware2,
        @course_ware3
      ]
    end

    it "最后一个向上移动两次" do
      @course_ware3.move_up.move_up
      CourseWare.all.should == [
        @course_ware3,
        @course_ware1,
        @course_ware2
      ]
    end

    it "第一个上下移动" do
      @course_ware1.move_down.move_up
      CourseWare.all.should == [
        @course_ware1,
        @course_ware2,
        @course_ware3
      ]
    end

    it "第一个向下移动" do
      @course_ware1.move_down
      CourseWare.all.should == [
        @course_ware2,
        @course_ware1,
        @course_ware3
      ]
    end

    it "第一个向下移动两次" do
      @course_ware1.move_down.move_down
      CourseWare.all.should == [
        @course_ware2,
        @course_ware3,
        @course_ware1
      ]
    end

  end

  describe '#is_video' do
    before {
      @cw_flv   = FactoryGirl.create :course_ware, :kind => 'flv'
    }

    it { @cw_flv.is_video?.should == true }
  end

end
