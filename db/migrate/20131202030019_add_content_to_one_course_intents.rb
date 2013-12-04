class AddContentToOneCourseIntents < ActiveRecord::Migration
  def change
    add_column :one_course_intents, :content, :text
  end
end
