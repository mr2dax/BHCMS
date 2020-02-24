class RemoveColsFromPages < ActiveRecord::Migration
 def up
    remove_column :pages, :text_size
    remove_column :pages, :text_font
  end

  def down
    add_column :pages, :text_size, :integer
    add_column :pages, :text_font, :string
  end
end