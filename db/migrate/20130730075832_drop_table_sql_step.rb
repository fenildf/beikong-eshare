class DropTableSqlStep < ActiveRecord::Migration
  def change
    drop_table :sql_steps
  end
end
