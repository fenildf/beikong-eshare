class RenameTeams < ActiveRecord::Migration
  def change
    rename_column :teams, :creator_id, :teacher_user_id
  end
end
