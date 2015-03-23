module AuthHelper
  def auth_wallpaper_tag
    # page_wallpaper "/assets/auth-ui/#{_auth_skin}/wallpaper.jpg"
    page_wallpaper SystemConfig.bg_img_url
  end

  def auth_logo
    capture_haml {
      haml_tag '.auth-logo' do
        # haml_tag 'img.logo', {:src => "/assets/auth-ui/#{_auth_skin}/logo.png"}
        haml_tag 'img.logo', {:src => SystemConfig.logo_img_url}
      end
    }
  end

  private
    def _auth_skin
      R::AUTH_SKIN
    rescue
      "default"
    end
end