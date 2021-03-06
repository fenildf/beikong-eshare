class TestPapersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @test_papers = TestPaper.all
  end

  def create
    @course = Course.find(params[:course_id])
    @test_paper = TestPaper.make_test_paper_for(@course,current_user)
    redirect_to :action => :edit, :id => @test_paper
  end

  def edit
    @test_paper = TestPaper.find(params[:id])
  end

  def show
    @test_paper = TestPaper.find(params[:id])
  end

  def destroy
    @test_paper = TestPaper.find(params[:id])
    @test_paper.destroy
    redirect_to course_path(@test_paper.course)
  end
end