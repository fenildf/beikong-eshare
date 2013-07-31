class CreateSelectCourseIntents < ActiveRecord::Migration
  def change
    create_table :select_course_intents do |t|
      t.integer :user_id          # 学生的 user_id
      t.integer :first_course_id  # 第一志愿
      t.integer :second_course_id # 第二志愿
      t.integer :third_course_id  # 第三志愿
      t.text    :opinion         
      t.timestamps
    end
  end
end
