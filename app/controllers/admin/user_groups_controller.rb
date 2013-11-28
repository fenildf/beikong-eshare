class Admin::UserGroupsController < ApplicationController
  require 'ostruct'
  before_filter :authenticate_user!

  def index
    authorize! :manage, User
    @users = User.page(params[:page]).order('id DESC').like_filter(@query = params[:q])

    @tab = params[:tab] || :teachers

    if @tab == :teachers
      @root_groups = GroupTreeNode.roots.with_teacher
    end

    if @tab == :students
      @root_groups = GroupTreeNode.roots.with_student
    end
  end

  def create
    parent_group_id = params[:parent_group_id].to_i

    name = params[:name]
    name = name.blank? ? '新分组' : name

    group = GroupTreeNode.create({
      :name => name,
      :kind => params[:kind]
    })

    if parent_group_id != 0
      group.move_to_child_of GroupTreeNode.find(parent_group_id)
    end

    depth = params[:parent_group_depth].to_i + 1
    render :json => {
      :html => (
        render_cell :group_tree, :node, :node => group, :depth => depth
      )
    }
  end

  def update
    group = GroupTreeNode.find params[:id]

    name = params[:name]
    name = name.blank? ? '新分组' : name

    group.name = name
    group.save

    render :json => {
      :name => name
    }
  end

  def destroy
    group = GroupTreeNode.find params[:id]
    if group.destroy
      return render :json => {
        :status => :ok
      }
    end

    render :status => 404
  end
end