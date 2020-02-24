class FixThemes < ActiveRecord::Migration
  def change
    rename_column :pages, :configuration_id, :theme_id
  end
end
