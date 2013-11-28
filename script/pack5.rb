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
    # TODO
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