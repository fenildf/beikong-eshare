# encoding: utf-8

class NoteUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include ImageUploaderMethods

  # 存储方式 本地硬盘存储
  storage :file

  # 当文件不存在时的默认 url
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
    "/assets/default_avatars/#{version_name}.png"
  end

  # 图片裁剪
  version :large do
    process :resize_to_fill => [180, 180]
  end
  # 图片裁剪
  version :normal do
    process :resize_to_fill => [300, 300]
  end

  version :small do
    process :resize_to_fill => [100, 100]
  end
end
