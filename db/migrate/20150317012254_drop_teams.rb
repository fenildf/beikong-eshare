class DropTeams < ActiveRecord::Migration
  def up
    drop_table :teams
    drop_table :team_memberships
  end

  def down
  end
end
