module CourseWareKindMethods
  CWKINDS = [
    'flv', 'ppt', 'pdf'
  ]

  CWKINDS.each do |k|
    define_method "is_#{k}?" do
      k == self.kind.to_s
    end
  end

  def is_pages?
    return is_ppt? || is_pdf?
  end

  # ---

  def is_video?
    return is_local_video?
  end

  def is_local_video?
    local_video_kinds = ['flv']
    local_video_kinds.include? self.kind.to_s
  end

end