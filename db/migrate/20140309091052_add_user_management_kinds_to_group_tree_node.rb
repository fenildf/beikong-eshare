class AddUserManagementKindsToGroupTreeNode < ActiveRecord::Migration
  def change
    add_column :group_tree_nodes, :group_kind, :string
    add_column :group_tree_nodes, :grade_kind, :string
    add_column :group_tree_nodes, :year, :string
  end
end
