class AddStatusToEntry < ActiveRecord::Migration[7.1]
  def change
    add_column :entries, :status, :string, default: "published"
  end
end
