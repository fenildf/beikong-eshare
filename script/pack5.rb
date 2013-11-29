# -*- coding: utf-8 -*-

defpack 5 do
  student_path = Rails.root.join('script/data/student.xlsx')
  student_data = Util.parse_excel(student_path, :student)

  teacher_path = Rails.root.join('script/data/teacher.xlsx')
  teacher_data = Util.parse_excel(teacher_path, :teacher)

  # {:login=>"t13352", :name=>"邹闻", :gender=>"", :group=>"英语教研组", :role=>:teacher}
end

class Util
  def self.import_user_by_data(data)
    if data[:role] == :teacher
      group_kind = GroupTreeNode::TEACHER
    elsif data[:role] == :student
      group_kind = GroupTreeNode::STUDENT
    end
    group_str = data.delete :group

    user = User.create!(data)
    if !group_str.blank?
      group = self.build_group(group_str, group_kind)
      group.add_user(user)
    end
  end

  # group_str 举例 "15届|split|高一|split|2班"
  # 表示三级分组 "15届" => "高一" => "2班"
  def self.build_group(group_str, group_kind)
    group_names = group_str.split("|split|")

    first_group = group_names.shift
    # 创建或者查找根分组
    current_group = GroupTreeNode.roots.find_by_name(first_group)
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
    data = []
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)


      login = row[0]
      name = row[1]
      gender = row[2]
      group = row[3]

      params = {
        :login  => login,
        :name   => name,
        :gender => gender || "",
        :group  => group,
        :role   => role
      }

      data << params
      p params
    end
    return data
  end
end