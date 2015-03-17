class CreateGroupTreeNodeUsers < ActiveRecord::Migration
  def change
    create_table :group_tree_node_users do |t|
      t.integer  :user_id
      t.integer  :group_tree_node_id
      t.timestamps
    end
  end
end
