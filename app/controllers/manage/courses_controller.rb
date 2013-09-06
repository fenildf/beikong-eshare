class Manage::CoursesController < ApplicationController
  before_filter :authenticate_user!
  
  before_filter :set_subsystem
  def set_subsystem
    @subsystem = :xuanke
  end

  # 课程申报
  def index
    authorize! :manage, Course

    if current_user.is_manager?
      @courses = Course.approve_status_with_not_yes.page(params[:page])
      return
    end

    @courses = Course.of_creator(current_user).page(params[:page])
  end

  def new
    authorize! :manage, Course
    @course = Course.new
  end

  def edit
    @course = Course.find params[:id]
    authorize! :manage, @course
  end

  def create
    authorize! :manage, Course

    @course = current_user.courses.build(params[:course])
    if @course.save 
      @course.set_teacher_users params[:teacher_ids]
      # @course.replace_public_tags(params[:course_tags], current_user)
      flash[:success] = '课程申报已经创建'
      return redirect_to :action => :index
    end
    render :action => :new
  end

  def update
    @course = Course.find params[:id]
    authorize! :manage, @course

    if @course.update_attributes(params[:course])
      @course.set_teacher_users params[:teacher_ids]
      # @course.replace_public_tags(params[:course_tags], current_user)
      flash[:success] = '课程申报修改成功'
      return redirect_to :action => :index
    end
    render :action => :edit
  end

  def show
    @course = Course.find params[:id]
    authorize! :manage, @course
    @chapters = @course.chapters
  end

  def destroy
    @course = Course.find params[:id]
    authorize! :manage, @course
    @course.destroy

    if request.xhr?
      return render :json => {:status => 'ok'}
    end

    redirect_to :action => :index, :q => cookies[:last_course_filter]
  end

  # -----------------------------

  def design
    @courses = Course.of_creator(current_user).page(params[:page])
  end

  def download_import_sample
    authorize! :manage, Course
    send_file Course.get_sample_excel_course, :filename => 'course_sample.xlsx'
  end

  def import
    authorize! :manage, Course
  end

  def do_import
    authorize! :manage, Course
    file = params[:excel_file]
    Course.import(file, current_user)
    redirect_to :action => :index
  end

  def import_youku_list
    authorize! :manage, Course
  end

  def import_youku_list_2
    authorize! :manage, Course
    @url = params[:url]
    @data = YoukuVideoList.new(@url).parse
  end

  def do_import_youku_list
    authorize! :manage, Course
    @url = params[:url]
    Course.import_youku_video_list(@url, current_user)

    redirect_to :action => :index
  end

  def import_tudou_list
    authorize! :manage, Course
  end

  def import_tudou_list_2
    authorize! :manage, Course
    @url = params[:url]
    @data = TudouVideoList.new(@url).parse
  end

  def do_import_tudou_list
    authorize! :manage, Course
    @url = params[:url]
    Course.import_tudou_video_list(@url, current_user)

    redirect_to :action => :index
  end

  def check
    authorize! :manage, Course
    @course = Course.find params[:id]
  end

  def check_yes
    authorize! :manage, Course
    @course = Course.find params[:id]
    @course.approve_status = 'YES'
    if @course.save
      return redirect_to :action => :index
    end
    redirect_to :action => :check
  end

  def check_no
    authorize! :manage, Course
    @course = Course.find params[:id]
    @course.approve_status = 'NO'
    if @course.save
      return redirect_to :action => :index
    end
    redirect_to :action => :check
  end
end