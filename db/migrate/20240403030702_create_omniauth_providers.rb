class CreateOmniauthProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :omniauth_providers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps
    end
  end
end
