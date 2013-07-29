class CreateCourseData < ActiveRecord::Migration
  def change
    create_table :course_data do |t|
      t.integer :file_entity_id
      t.integer :course_id

      t.timestamp
    end
  end
end
