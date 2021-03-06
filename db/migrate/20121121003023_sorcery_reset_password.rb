class SorceryResetPassword < ActiveRecord::Migration
  def self.up
    add_column :vendors, :reset_password_token, :string, :default => nil
    add_column :vendors, :reset_password_token_expires_at, :datetime, :default => nil
    add_column :vendors, :reset_password_email_sent_at, :datetime, :default => nil
    
    add_index :vendors, :reset_password_token
  end

  def self.down
    remove_index :vendors, :reset_password_token
    
    remove_column :vendors, :reset_password_email_sent_at
    remove_column :vendors, :reset_password_token_expires_at
    remove_column :vendors, :reset_password_token
  end
end