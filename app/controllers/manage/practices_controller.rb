class Manage::PracticesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @practice = current_user.practices.build
  end

  def edit
    @practice = Practice.find params[:id]
  end

  def create
    @chapter = Chapter.find params[:chapter_id]

    @practice = @chapter.practices.build params[:practice]
    @practice.creator = current_user

    if params[:file_entity_id].present?
      fe = FileEntity.find(params[:file_entity_id])
      @practice.file_entities = [fe]
    end

    if @practice.save
      return redirect_to '/manage/practices'
    end

    render :new
  end

  def update
    @practice = Practice.find params[:id]

    @practice.title = params[:practice][:title]
    @practice.content = params[:practice][:content]

    if params[:file_entity_id].present?
      fe = FileEntity.find(params[:file_entity_id])
      @practice.file_entities = [fe]
    end

    @practice.save(:validate => false)

    return redirect_to '/manage/practices'
  end

  def index
    @practices = current_user.practices.page params[:page]
  end

  def show
    @practice = current_user.practices.find params[:id]
  end

  def destroy
    @practice = Practice.find params[:id]
    @practice.destroy
    redirect_to :back
  end
end