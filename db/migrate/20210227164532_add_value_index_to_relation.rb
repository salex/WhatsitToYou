class AddValueIndexToRelation < ActiveRecord::Migration[6.1]
  def change
    add_index :relations, :value_id
  end
end
