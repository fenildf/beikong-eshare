# -*- coding: utf-8 -*-
class IndexController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  layout 'dashboard', :only => [:dashboard]

  def index
    if !user_signed_in?
      return redirect_to '/account/sign_in'
    end

    return redirect_to '/dashboard'
  end

  def dashboard
    # 教师和学生的工作台页面
  end

end
