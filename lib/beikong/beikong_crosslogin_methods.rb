module BeikongCrossloginMethods
  require 'openssl'

  BEIKONG_CL_DOMAIN = "http://60.247.110.152:8080"
  BEIKONG_SYS_ID = "2"
  PUBLIC_KEY = %~-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCX+Uv+VjgUJxjjN+UYb+0MkeeQ
kz+MObVFVNq+eSmIJgyfh2likIKjHqLvIWOlEh5/EwrOEAAVZrf/Cf3ZA6LLJXlO
vNwmydlXmXk+hWAvy8XFSzOEf5nUofE9N/3Kyp9avi3HWjvmsEPuKNv0Cz7SmsTM
crLEvZckg+ekrcrkgQIDAQAB
-----END PUBLIC KEY-----~

  def self.included(base)
    # 北控单点登录
    base.before_filter :beikong_cross_login
  end

  def beikong_cross_login
    _gen_bk_session_key

    if !current_user
      return true if request.path == '/account/sign_out'

      if request.path == '/bk_login' # /bk_jump
        # return render :json => {
        #   :key => params[:authtest_key],
        #   :name => params[:authtest_username]
        # }

        check_params params[:authtest_key], params[:authtest_username]
        check_params params[:auth_key], params[:auth_username]

        return true
      end

      _do_cross_login
    end
  end

private
  def check_params(key, user_name)
    if !key.blank? && !user_name.blank?
      if _verify(session[:bk_crosslogin_auth_key], user_name, key)
        sign_in(:user, _get_user(user_name))
        redirect_to "/"
      end
    end
  end

  def _get_user(user_name)
    url = 
      "#{bk_cl_domain}/uas/authInfoAction.a?" + 
      "becom_auth_username=#{user_name}&" +
      "userinfoparameter=user_type,name,user_name,email"

    uri = URI(url)

    data = Net::HTTP.get(uri)

    doc = Nokogiri::XML(data)
    
    email = doc.css('email').text
    login = doc.css('user_name').text
    name = doc.css('name').text
    ro = doc.css('user_type').text
    role = {
      '学生' => :student,
      '教师' => :teacher,
      '其他' => :student
    }[ro]

    user = User.find_by_login login
    return user if !user.blank?
    return User.create({
      :name  => name,
      :login => login,
      :role  => role
    })

  end

  def bk_cl_domain
    BEIKONG_CL_DOMAIN
  end

  def sys_id
    BEIKONG_SYS_ID
  end

  def _gen_bk_session_key
    session[:bk_crosslogin_auth_key] ||= randstr
  end

  def _do_cross_login
    authtest_url = "http://" + request.host_with_port + "/bk_login"  # /bk_jump
    authtest_key = session[:bk_crosslogin_auth_key]

    url = 
      "#{bk_cl_domain}/uas/authTestNewAction.a?" +
      "authtest_url=#{authtest_url}&" +
      "authtest_key=#{authtest_key}&" +
      "sys_id=#{sys_id}"

    # render :text => url
    redirect_to url
  end

  # 第一个参数是传给验证服务的
  # 第二个参数是传回来的
  def _verify(session_key, user_name, sign)
    sign_d = sign.split(/(.{2})/).select do |str|
      str != ""
    end.map do |num|
      num.hex.chr
    end*""
    # pkey = OpenSSL::PKey::RSA.new(File.read("./public_key"))
    pkey = OpenSSL::PKey::RSA.new(PUBLIC_KEY)
    pkey.verify(OpenSSL::Digest::MD5.new, sign_d, session_key + user_name)
  end
end