class CreateGroupTreeNodes < ActiveRecord::Migration
  def change
    create_table :group_tree_nodes do |t|
      t.string :kind
      t.string :name
      t.integer :parent_id
      t.integer :manage_user_id

      t.timestamps
    end
  end
end
