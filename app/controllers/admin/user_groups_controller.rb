class Admin::UserGroupsController < ApplicationController
  require 'ostruct'
  before_filter :authenticate_user!

  def index
    authorize! :manage, User
    @users = User.page(params[:page]).order('id DESC').like_filter(@query = params[:q])

    @tab = params[:tab] || :teachers

    if @tab == :teachers
      @root = _root_group(GroupTreeNode::TEACHER)
    end

    if @tab == :students
      @root = _root_group(GroupTreeNode::STUDENT)
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

  def show
    id = params[:id]
    kind = params[:kind]

    if id == '-1'
      group = _non_group(kind)
      users = User.with_role(kind.downcase).without_group.page(params[:page])
    elsif id == '0'
      group = _root_group(kind)
      users = User.with_role(kind.downcase).with_group.page(params[:page])
    else
      group = GroupTreeNode.find id
      users = group.nest_members.page(params[:page])
    end

    return render :json => {
      :rid => params[:rid],
      :html => (
        render_cell :group_tree, :show, :node => group, :users => users
      )
    }
  end

  def add_user_form
    to_group_id   = params[:id]
    from_group_id = params[:from]
    kind          = params[:kind]

    to_group   = GroupTreeNode.find to_group_id

    if from_group_id == '-1'
      from_group = _non_group(kind)
      users = User.with_role(kind.downcase).without_group.page(params[:page])
    elsif from_group_id == '0'
      from_group = _root_group(kind)
      users = User.with_role(kind.downcase).with_group.page(params[:page])
    else
      from_group = GroupTreeNode.find from_group_id
      users = from_group.nest_members.page(params[:page])
    end

    return render :json => {
      :rid => params[:rid],
      :html => (
        render_cell :group_tree, :user_selector, 
                                 :node => to_group, 
                                 :root => _root_group(kind),
                                 :users => users
      )
    }
  end

private

  def _root_group(kind)
    if kind == GroupTreeNode::TEACHER
      root_groups = GroupTreeNode.roots.with_teacher
      str = '教职工'
    end

    if kind == GroupTreeNode::STUDENT
      root_groups = GroupTreeNode.roots.with_student
      str = '学生'
    end

    OpenStruct.new({
      :id => '0',
      :name => "已分组#{str}",
      :children => root_groups,
      :kind => kind,
      :nest_members => []
    })
  end

  def _non_group(kind)
    if kind == GroupTreeNode::TEACHER
      str = '教职工'
    end

    if kind == GroupTreeNode::STUDENT
      str = '学生'
    end

    OpenStruct.new({
      :id => '-1',
      :name => "未分组#{str}",
      :children => [],
      :kind => kind
    })
  end
end