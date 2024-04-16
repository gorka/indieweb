class CreateBlogs < ActiveRecord::Migration[7.1]
  def change
    create_table :blogs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :subdomain, null: false
      t.string :authorization_endpoint
      t.string :token_endpoint

      t.timestamps
    end

    add_index :blogs, :subdomain, unique: true
  end
end
