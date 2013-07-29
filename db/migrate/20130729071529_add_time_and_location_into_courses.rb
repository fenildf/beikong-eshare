class AddTimeAndLocationIntoCourses < ActiveRecord::Migration
  def change
    add_column :courses, :is_approved, :boolean, :default => false  # 审批
    add_column :courses, :time,     :string   # 上课时间安排
    add_column :courses, :location, :string   # 上课地点
  end
end
