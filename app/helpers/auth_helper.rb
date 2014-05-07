module AuthHelper
  def auth_wallpaper_tag
    page_wallpaper "/assets/auth-ui/#{_auth_skin}/wallpaper.jpg"
  end

  def auth_logo
    capture_haml {
      haml_tag '.auth-logo' do
        haml_tag 'img.logo', {:src => "/assets/auth-ui/#{_auth_skin}/logo.png"}
      end
    }
  end

  private
    def _auth_skin
      R::AUTH_SKIN || "default"
    end
end