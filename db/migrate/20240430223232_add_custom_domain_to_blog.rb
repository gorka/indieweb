class AddCustomDomainToBlog < ActiveRecord::Migration[7.1]
  def change
    add_column :blogs, :custom_domain, :string
  end
end
