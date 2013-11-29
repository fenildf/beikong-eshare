class AddLftAndRgtToGroupTreeNodes < ActiveRecord::Migration
  def change
    add_column :group_tree_nodes, :lft, :integer
    add_column :group_tree_nodes, :rgt, :integer
  end
end
