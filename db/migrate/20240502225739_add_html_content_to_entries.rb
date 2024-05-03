class AddHtmlContentToEntries < ActiveRecord::Migration[7.1]
  def up
    add_column :entries, :html_content, :text

    Entry.where.not(name: nil).each do |entry|
      entry.update! html_content: entry.content, content: nil
    end
  end

  def down
    remove_column :entries, :html_content
  end
end
