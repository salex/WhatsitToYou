class CreateRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :relations do |t|
      t.string :name
      t.references :subject, null: false, foreign_key: true
      t.bigint :value_id, null: false, foreign_key: true

      t.timestamps
    end
    add_index :relations, :name
  end
end
