class SorceryUserActivation < ActiveRecord::Migration
  def self.up
    add_column :vendors, :activation_state, :string, :default => nil
    add_column :vendors, :activation_token, :string, :default => nil
    add_column :vendors, :activation_token_expires_at, :datetime, :default => nil
    
    add_index :vendors, :activation_token
  end

  def self.down
    remove_index :vendors, :activation_token
    
    remove_column :vendors, :activation_token_expires_at
    remove_column :vendors, :activation_token
    remove_column :vendors, :activation_state
  end
end