module MediaResourceDownload
  def download_id
    Base64.encode64("#{creator.id},#{id}").strip
  end

  def download_link
    "/download/#{download_id}"
  end

  def share_link
    "/disk/s/#{download_id}"
  end
end
