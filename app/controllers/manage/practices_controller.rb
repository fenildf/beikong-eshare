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
      @practice.attaches_attributes = [
        {:file_entity => FileEntity.find(params[:file_entity_id]), :name => '附件'}
      ]
    end

    if @practice.save
      return redirect_to '/manage/practices'
    end

    render :new
  end

  def update
    
  end

  def index
    @practices = current_user.practices.page params[:page]
  end

  def show
    @practice = current_user.practices.find params[:id]
  end
end