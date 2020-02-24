class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :bg_color, :null => false, :limit => 7
      t.string :main_text_color, :null => false, :limit => 7
      t.string :normal_text_color, :null => false, :limit => 7
      t.string :button_color, :null => false, :limit => 7
      t.timestamps
    end
  end
end
