module UserGenderMethods
  def self.included(base)
    base.after_save :_build_gender
  end

  def _build_gender
    return true if self.role.blank?
    return true if !@has_set_gender

    if role?(:teacher)
      self.teacher_attrs_gender = _parse_gender_str_to_int(@gender)
      self._clear_set_gender_flag
      # 这里不用 self.save
      # 是因为这里如果运行 self.save 
      # 会导致 redis-search 插件的一个逻辑抛出异常
      # --- fushang318
      self.teacher_attrs.save
    end
    if role?(:student)
      self.student_attrs_gender = _parse_gender_str_to_int(@gender)
      self._clear_set_gender_flag
      # 这里不用 self.save
      # 是因为这里如果运行 self.save 
      # 会导致 redis-search 插件的一个逻辑抛出异常
      # --- fushang318
      self.student_attrs.save
    end
  end

  def gender
    return @gender if @has_set_gender

    if role?(:teacher)
      return _parse_gender_int_to_str(self.teacher_attrs_gender)
    end
    if role?(:student)
      return _parse_gender_int_to_str(self.student_attrs_gender)
    end
    return ""
  end

  def gender=(gender)
    @gender = gender
    @has_set_gender = true
  end

  def _clear_set_gender_flag
    @has_set_gender = false
  end

  def _parse_gender_int_to_str(num)
    case num
    when 1 then '男'
    when 2 then '女'
    else 
      ''
    end
  end

  def _parse_gender_str_to_int(str)
    case str
    when '男' then 1
    when '女' then 2
    else 
      nil
    end
  end

end