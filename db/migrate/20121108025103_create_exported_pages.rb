class CreateExportedPages < ActiveRecord::Migration
  def change
    create_table :exported_pages do |t|
      t.string :file_path, :null => false, :limit => 256
      t.timestamps
    end
  end
end
