class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :file_path, :null => false, :limit => 256
      t.timestamps
    end
  end
end
