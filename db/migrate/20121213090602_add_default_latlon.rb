class AddDefaultLatlon < ActiveRecord::Migration
 def change
    change_column :sites, :latitude, :decimal, :precision => 9, :scale => 6, :null => false, :default => '35.692984'
    change_column :sites, :longitude, :decimal, :precision => 9, :scale => 6, :null => false, :default => '139.754232'
  end
end