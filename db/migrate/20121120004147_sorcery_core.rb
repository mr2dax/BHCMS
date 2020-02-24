class SorceryCore < ActiveRecord::Migration
  def change
      rename_column :vendors, :password_digest, :crypted_password
      add_column :vendors, :salt, :string, :limit => 255
  end
end
