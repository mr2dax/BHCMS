class EditUploads < ActiveRecord::Migration
  def up
    add_column :uploads, :vendor_id, :integer
    add_column :uploads, :site_id, :integer
    add_column :uploads, :desc, :string
  end

  def down
    remove_column :uploads, :vendor_id
    remove_column :uploads, :site_id
    remove_column :uploads, :desc
  end
end
