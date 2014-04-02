class AddStudentAndTeacherGenderColumn < ActiveRecord::Migration
  def change
    AttrsConfig.create(
      :role       => 'teacher',
      :field      => 'gender',
      :field_type => 'integer'
    )
    AttrsConfig.create(
      :role       => 'student',
      :field      => 'gender',
      :field_type => 'integer'
    )
  end
end
