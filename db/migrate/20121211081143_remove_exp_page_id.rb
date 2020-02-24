class RemoveExpPageId < ActiveRecord::Migration
  def change
    remove_column :pages, :exp_page_id
  end
end
