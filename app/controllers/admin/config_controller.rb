class Admin::ConfigController < ApplicationController
  before_filter :authenticate_user!

  def auth_image
    @bg_url = SystemConfig.bg_img_url
    @logo_url = SystemConfig.logo_img_url
  end

  def do_auth_image
    if params[:default]
      SystemConfig.set_bg_img_to_default
      SystemConfig.set_logo_img_to_default
    end

    if params[:bg_id].present?
      SystemConfig.set_bg_img params[:bg_id]
    end

    if params[:logo_id].present?
      SystemConfig.set_logo_img params[:logo_id]
    end

    redirect_to :action => :auth_image
  end
end