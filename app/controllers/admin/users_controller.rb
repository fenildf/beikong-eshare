class Admin::UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :manage, User
    @users = User.page(params[:page]).order('id DESC').like_filter(@query = params[:q])

    @tab = params[:tab] || :teachers

    require 'ostruct'
    @root_groups = [
      OpenStruct.new(:name => '初中部', :id => 0),
      OpenStruct.new(:name => '高中部', :id => 1, :children => [
        OpenStruct.new(:name => '2016届', :id => 2),
        OpenStruct.new(:name => '2015届', :id => 3),
        OpenStruct.new(:name => '2014届', :id => 4),
      ]),
      OpenStruct.new(:name => '素质班', :id => 5),
      OpenStruct.new(:name => '我的名字就是长你能拿我怎么样我的名字就是长你能拿我怎么样', :id => 6, :children => [
        OpenStruct.new(:name => 'test-1', :id => 7),
        OpenStruct.new(:name => 'test-2', :id => 8),
      ]),
      OpenStruct.new(:name => '有关部门-1', :id => 9),
      OpenStruct.new(:name => '有关部门-2', :id => 10),
      OpenStruct.new(:name => '有关部门-3', :id => 11),
      OpenStruct.new(:name => '有关部门-4', :id => 12),
      OpenStruct.new(:name => '有关部门-5', :id => 13),
      OpenStruct.new(:name => '有关部门-6', :id => 14),
      OpenStruct.new(:name => '有关部门-7', :id => 15),
      OpenStruct.new(:name => '有关部门-8', :id => 16),
      OpenStruct.new(:name => '有关部门-9', :id => 17),
      OpenStruct.new(:name => '有关部门-10', :id => 18),
      OpenStruct.new(:name => '有关部门-11', :id => 19),
    ]
  end

  def edit
    @user = User.find(params[:id])
    authorize! :manage, @user
  end

  def update
    _update_user(:manage_change_base_info)
  end

  def new
    authorize! :manage, User
    @user = User.new
  end

  def create
    authorize! :manage, User
    @user = User.new(params[:user])
    if @user.save
      return redirect_to :action => :index
    end
    render :action => :new
  end

  def destroy
    @user = User.find params[:id]
    authorize! :manage, @user
    @user.destroy
    redirect_to :action => :index
  end

  # ---------------

  def change_password
    _update_user(:change_password)
  end

  def student_attrs
    @user = User.find(params[:id])
    authorize! :manage, @user
    redirect_if_not(@user, :student)
  end

  def teacher_attrs
    @user = User.find(params[:id])
    authorize! :manage, @user
    redirect_if_not(@user, :teacher)
  end

  def user_attrs_update
    @user = User.find(params[:id])
    authorize! :manage, @user
    @user.update_attributes(params[:user])
    @user.save
    redirect_to user_attrs_path(@user)
  end

  def download_import_sample
    authorize! :manage, User
    send_file User.get_sample_excel_student, :filename => 'user_sample.xlsx'
  end

  def import
    authorize! :manage, User
  end

  def do_import
    authorize! :manage, User
    file = params[:excel_file]
    User.import_excel(file, :student, '1234')
    redirect_to :action => :index
  end

protected

  def redirect_if_not(user, role)
    redirect_to admin_root_path if !user.role?(role)
  end

  def user_attrs_path(user)
    return student_attrs_admin_user_path(user) if user.role? :student
    teacher_attrs_admin_user_path(user)
  end

private

  def _update_user(as)
    @user = User.find(params[:id])
    authorize! :manage, @user
    if @user.update_attributes(params[:user], :as => as)
      return redirect_to "/admin/users/#{@user.id}/edit"
    end
    render :action => :edit
  end
end
