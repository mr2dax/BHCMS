class AddDetailToTemplates < ActiveRecord::Migration
 def up
    add_column :templates, :vendor_id, :integer
    add_column :templates, :description, :string
    drop_table :exported_pages
  end

  def down
    remove_column :templates, :vendor_id
    remove_column :templates, :description
    raise ActiveRecord::IrreversibleMigration
  end
end