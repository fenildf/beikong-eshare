class TeamsController < ApplicationController
  before_filter :authenticate_user!

  def mine
  end

  def show
    @group = GroupTreeNode.find params[:id]
  end
end