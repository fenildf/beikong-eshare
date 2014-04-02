# -*- coding: utf-8 -*-

defpack 5 do
  student_path = "/download/user_data/students.xls"
  p "导入学生"
  student_data_arr = Util.parse_excel(student_path, :student)
  Util.import_user_by_data(student_data_arr)

  teacher_path = "/download/user_data/teachers.xls"
  p "导入老师"
  teacher_data_arr = Util.parse_excel(teacher_path, :teacher)
  Util.import_user_by_data(teacher_data_arr)
end

class Util
  def self.import_user_by_data(data_arr)
    count = data_arr.count
    data_arr.each_with_index do |data,index|
      p "#{index+1}/#{count}"

      next if !User.where(:login => data[:login]).blank?

      if data[:role] == :teacher
        group_kind = GroupTreeNode::TEACHER
      elsif data[:role] == :student
        group_kind = GroupTreeNode::STUDENT
      end
      group_str = data.delete :group
      p data
      user = User.create!(data)
      if !group_str.blank?
        group = self.build_group(group_str, group_kind)
        group.add_user(user)
      end
    end
  end

  # group_str 举例 "15届|split|高一|split|2班"
  # 表示三级分组 "15届" => "高一" => "2班"
  def self.build_group(group_str, group_kind)
    group_names = group_str.split("|")

    first_group = group_names.shift
    # 创建或者查找根分组
    current_group = GroupTreeNode.roots.where(:name => first_group, :kind => group_kind).first
    if current_group.blank?
      current_group = GroupTreeNode.create!(
        :name => first_group,
        :kind => group_kind
      )
    end

    # 创建或者查找下级分组
    group_names.each do |group_name|
      tg = current_group.children.find_by_name(group_name)
      if tg.blank?
        tg = GroupTreeNode.create!(
          :name => group_name,
          :kind => group_kind
        )
        tg.move_to_child_of(current_group)
      end

      current_group = tg
    end

    return current_group
  end

  def self.parse_excel(path, role)
    file = File.open(path,"r")
    spreadsheet = SimpleExcelImport::ImportFile.open_spreadsheet(file)
    data_arr = []
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)


      login = row[0]
      login = login.floor.to_s if login.class != String
      name = row[1]
      password = row[2]
      if role == :student
        group = "高中部|#{row[6]}|#{row[7]}"
      else
        group = row[6]
      end

      params = {
        :login  => login,
        :name   => name,
        :password => password,
        :group  => group,
        :role   => role
      }
      
      data_arr << params
    end
    return data_arr
  end
end