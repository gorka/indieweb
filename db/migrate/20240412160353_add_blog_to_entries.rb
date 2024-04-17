class AddBlogToEntries < ActiveRecord::Migration[7.1]
  def change
    add_reference :entries, :blog, null: false, foreign_key: true
  end
end
