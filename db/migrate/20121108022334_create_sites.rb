class CreateSites < ActiveRecord::Migration
  
  def change
    create_table :sites do |t|
      t.integer :vendor_id, :null => false
      t.integer :landing_page_id
      t.string  :site_name, :null => false, :default => 'Untitled', :limit => 128
      t.string  :site_type, :limit => 128
      t.decimal :latitude, :precision => 8, :scale => 6
      t.decimal :longitude, :precision => 9, :scale => 6
      t.string  :logo_path, :limit => 256
      t.text    :description
      t.timestamps
    end
  end
end
