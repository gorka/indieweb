class CreateMicroformatPhotos < ActiveRecord::Migration[7.1]
  def change
    create_table :microformat_photos do |t|
      t.references :photo_with_alt, null: false, foreign_key: { to_table: :photos_with_alt }
      t.references :photoable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
