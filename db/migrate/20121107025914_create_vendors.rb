class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :vendor_name
      t.string :username
      t.string :password_digest      
      t.string :contact_person
      t.string :address
      t.string :email
      t.string :telephone

      t.timestamps
    end
  end
end
