class CreateGroupTreeNodes < ActiveRecord::Migration
  def change
    create_table :group_tree_nodes do |t|
      t.string  :kind
      t.string  :name
      t.integer :parent_id
      t.integer :manage_user_id
      t.integer :lft
      t.integer :rgt
      t.string  :group_kind
      t.string  :grade_kind
      t.string  :year
      t.timestamps
    end
  end
end
