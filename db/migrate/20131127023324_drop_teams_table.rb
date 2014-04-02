class DropTeamsTable < ActiveRecord::Migration
  def change
    drop_table :teams
    drop_table :team_memberships
  end
end
