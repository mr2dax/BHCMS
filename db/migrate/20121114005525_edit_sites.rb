class EditSites < ActiveRecord::Migration
  def change
    add_column :sites, :address, :string, :limit => 255
    add_column :sites, :telephone, :string, :limit => 255
    rename_column :sites, :logo_path, :logo
  end
end
