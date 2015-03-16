class Manage::CourseWaresController < ApplicationController
  before_filter :authenticate_user!
  layout :get_layout
  def get_layout
    return 'manage'
  end
  
  def index
    authorize! :manage, CourseWare
    @chapter = Chapter.find(params[:chapter_id])
  end

  def new
    authorize! :manage, CourseWare
    @chapter = Chapter.find(params[:chapter_id])
    @course_ware = @chapter.course_wares.new
  end


  def create
    authorize! :manage, CourseWare
    @chapter = Chapter.find(params[:chapter_id])
    @course_ware = @chapter.course_wares.build(params[:course_ware], :as => :upload)
    @course_ware.creator = current_user
    if @course_ware.save
      return redirect_to "/manage/chapters/#{@chapter.id}"
    end
    render :action => :new
  end

  def edit
    @course_ware = CourseWare.find(params[:id])
    authorize! :manage, @course_ware
    @chapter = @course_ware.chapter
    @select_chapters = @chapter.course.chapters
  end

  def update
    @course_ware = CourseWare.find(params[:id])
    authorize! :manage, @course_ware
    @chapter = @course_ware.chapter
    if @course_ware.update_attributes(params[:course_ware], :as => :upload)
      return redirect_to "/manage/chapters/#{@chapter.id}"
    end
    render :action => :edit
  end

  def destroy
    @course_ware = CourseWare.find(params[:id])
    authorize! :manage, @course_ware
    @chapter = @course_ware.chapter
    @course_ware.destroy

    if request.xhr?
      return render :json => {:status => 'ok'}
    end

    return redirect_to "/manage/chapters/#{@chapter.id}"
  end

  def move_up
    @course_ware = CourseWare.find(params[:id])
    authorize! :manage, @course_ware
    @chapter = @course_ware.chapter
    @course_ware.move_up

    if request.xhr?
      return render :json => {
        :status => 'ok',
        :html => (render_cell :course_ware, :manage_table, :course_wares => [@course_ware])
      }
    end

    return redirect_to "/manage/chapters/#{@chapter.id}"
  end

  def move_down
    @course_ware = CourseWare.find(params[:id])
    authorize! :manage, @course_ware
    @chapter = @course_ware.chapter
    @course_ware.move_down

    if request.xhr?
      return render :json => {
        :status => 'ok',
        :html => (render_cell :course_ware, :manage_table, :course_wares => [@course_ware])
      }
    end

    return redirect_to "/manage/chapters/#{@chapter.id}"
  end

  def do_convert
    @course_ware = CourseWare.find(params[:id])
    authorize! :manage, @course_ware
    @chapter = @course_ware.chapter
    
    @course_ware.file_entity.do_convert(true)

    return redirect_to "/manage/chapters/#{@chapter.id}"
  end



end