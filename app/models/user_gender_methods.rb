module UserGenderMethods
  def self.included(base)
    base.validates :student_attrs_gender, 
      :inclusion => { :in => [nil, "", "男", "女"] },
      :if => lambda { |user| user.role?(:student) }
    base.validates :teacher_attrs_gender, 
      :inclusion => { :in => [nil, "", "男", "女"] },
      :if => lambda { |user| user.role?(:teacher) }
  end

  def gender
    if role?(:teacher)
      return _parse_gender_int_to_str(self.teacher_attrs_gender)
    end
    if role?(:student)
      return _parse_gender_int_to_str(self.student_attrs_gender)
    end
    return ""
  end

  def gender=(gender)
    if role?(:teacher)
      self.teacher_attrs_gender = _parse_gender_str_to_int(gender)
    end
    if role?(:student)
      self.student_attrs_gender = _parse_gender_str_to_int(gender)
    end
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