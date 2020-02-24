class SorceryBruteForceProtection < ActiveRecord::Migration
  def self.up
    add_column :vendors, :failed_logins_count, :integer, :default => 0
    add_column :vendors, :lock_expires_at, :datetime, :default => nil
    add_column :vendors, :unlock_token, :string, :default => nil
  end

  def self.down
    remove_column :vendors, :lock_expires_at
    remove_column :vendors, :failed_logins_count
    remove_column :vendors, :unlock_token
  end
end