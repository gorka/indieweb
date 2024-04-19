class AddNameToEntries < ActiveRecord::Migration[7.1]
  def change
    add_column :entries, :name, :string
  end
end
