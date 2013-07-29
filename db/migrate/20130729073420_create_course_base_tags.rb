class CreateCourseBaseTags < ActiveRecord::Migration
  def up
    create_table :course_base_tags do |t|
      t.string :name
    end
  end
end


