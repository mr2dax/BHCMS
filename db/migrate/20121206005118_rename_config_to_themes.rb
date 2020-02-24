class RenameConfigToThemes < ActiveRecord::Migration
    def change
        rename_table :configurations, :themes
    end 
end
