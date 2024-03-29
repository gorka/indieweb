class CreateCategorizations < ActiveRecord::Migration[7.1]
  def change
    create_table :categorizations do |t|
      t.references :category, null: false, foreign_key: true
      t.references :categorizable, polymorphic: true, null: false
      t.index [:category_id, :categorizable_type, :categorizable_id], unique: true, name: "unique_category_categorizable"

      t.timestamps
    end
  end
end
