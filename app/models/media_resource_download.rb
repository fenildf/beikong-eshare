module MediaResourceDownload
  def download_id
    Base64.encode64("#{creator.id},#{file_entity.id},#{name}").strip
  end

  def download_link
    "/download/#{download_id}"
  end
end
