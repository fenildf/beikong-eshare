class SystemConfig < ActiveRecord::Base
  DEFAULT_BG_IMG_URL   = "/bg_img.png"
  DEFAULT_LOGO_IMG_URL = "/logo_img.png"
  
  # 获取背景图(如果没有设置过，就返回系统默认的)
  def self.bg_img_url
    _init
    bg_img_file_entity_id = self.first.bg_img_file_entity_id
    return DEFAULT_BG_IMG_URL if bg_img_file_entity_id.blank?

    FileEntity.find(bg_img_file_entity_id).attach.url
  end

  # 获取 logo图（如果没有设置过，就返回系统默认的）
  def self.logo_img_url
    _init
    logo_img_file_entity_id = self.first.logo_img_file_entity_id
    return DEFAULT_LOGO_IMG_URL if logo_img_file_entity_id.blank?

    FileEntity.find(logo_img_file_entity_id).attach.url
  end

  # 设置 背景图
  def self.set_bg_img(file_entity_id)
    config = self.first
    config.bg_img_file_entity_id = file_entity_id
    config.save
  end

  # 设置 logo图
  def self.set_logo_img(file_entity_id)
    config = self.first
    config.logo_img_file_entity_id = file_entity_id
    config.save
  end

  def self._init
    self.create if self.count == 0
  end

end
