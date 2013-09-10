class SessionsController < Devise::SessionsController
  layout Proc.new { |controller|
    if controller.request.headers['X-PJAX']
      return false
    end

    case controller.action_name
    when 'new', 'new_xuanke', 'new_eshare'
      return 'auth'
    end
  }

  def new
    super
    # 在这里添加其他逻辑
  end

  def new_xuanke
    @for = :xuanke
    self.new
  end

  def new_eshare
    @for = :eshare
    self.new
  end

  def create
    if !request.xhr?
      return super
    end

    if params[:to] == 'xuanke'
      redirect_path = '/'
    else
      redirect_path = '/'
    end

    flash[:sign_in_to] = params[:sign_in_to]
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    # render :json => {:sign_in => 'ok', :location => after_sign_in_path_for(resource)} # 必须响应 json 否则会被 jquery 判为 error
    render :json => {:sign_in => 'ok', :location => redirect_path} # 必须响应 json 否则会被 jquery 判为 error
  end

  def destroy
    # redirect_path = after_sign_out_path_for(resource_name)
    if params[:to] == 'xuanke'
      redirect_path = '/xk/sign_in'
    else
      redirect_path = '/eshare/sign_in'
    end

    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_navigational_format?

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end
end