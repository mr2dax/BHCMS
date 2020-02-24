class AddLogoToVendor < ActiveRecord::Migration
  def self.up
    add_column :vendors, :logo, :string, :limit => 256
  end

  def self.down
    remove_column :vendors, :logo
  end
end
