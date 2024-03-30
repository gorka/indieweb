class CreatePhotosWithAlt < ActiveRecord::Migration[7.1]
  def change
    create_table :photos_with_alt do |t|
      t.string :alt

      t.timestamps
    end
  end
end
