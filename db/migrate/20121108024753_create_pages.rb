class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :site_id, :null => false
      t.integer :template_id, :null => false
      t.string :page_name, :null => false, :default => 'Untitled', :limit => 128
      t.integer :text_size, :default => 3
      t.string :text_font, :limit => 256
      t.string :language, :limit =>2
      t.integer :exp_page_id
      t.integer :configuration_id

      t.timestamps
    end
  end
end
