class Vendor < ActiveRecord::Base
  authenticates_with_sorcery!
  attr_accessible :id, :vendor_name, :username, :password, :password_confirmation, :contact_person, :address, :email, :telephone, :logo, :vendor_logo
  attr_accessor :vendor_logo_file_name
  attr_accessor :vendor_logo_content_type
  attr_accessor :vendor_logo_file_size
  attr_accessor :vendor_logo_updated_at

  has_attached_file :vendor_logo, :url => ":rails_root/public/vendorlogos/:id.:extension",
    :path => ":rails_root/public/vendorlogos/:id.:extension"
  validates_attachment_content_type :vendor_logo, :content_type => [ 'image/jpeg', 'image/jpg', 'image/png' ],
                                    :message => 'allowed extensions are: jpg, jpeg or png !'
  before_save   :edit_logo_path
  before_update :delete_previous_logo
  after_save    :rename_file
  # paperclip problem with japanese characters in filename => file has no extension after arriving to the server => granting extension from db
  def rename_file
    @old_path = Rails.root.to_s+'/public/vendorlogos/'+self.id.to_s
    @new_path = Rails.root.to_s+'/public/vendorlogos/'+self.id.to_s+"."+self.logo.to_s
      if(File.exists?(@old_path))
        File.rename(@old_path, @new_path)
    end
  end
  #edit the logo path to include only the extension of the image for the vendor logo
  def edit_logo_path 
    # check if not a new vendor
    if Vendor.exists?(self.id)
      begin
        # previous vendor logo's extension in the db
        @last_extension = Vendor.find_by_id(self.id)
        # vendor_logo.url from paperclip (no image attached error message), self.logo from vendors/_form.html (no image selected to be uploaded)
        if self.vendor_logo.url().split('?')[0] == "/vendor_logos/original/missing.png" && self.logo == "vendorlogos/logo.jpg"
            # if there was no image selected at edit take the previous extension from db
            self.logo = @last_extension.logo
            # if there was a single/multiple value update then use the previous extension from db (for future implementations if need be)
        elsif self.vendor_logo.url().split('?')[0] == "/vendor_logos/original/missing.png" && self.logo == "jpg"
            self.logo = @last_extension.logo
        elsif self.vendor_logo.url().split('?')[0] == "/vendor_logos/original/missing.png" && self.logo == "png"
            self.logo = @last_extension.logo
        elsif self.vendor_logo.url().split('?')[0] == "/vendor_logos/original/missing.png" && self.logo == "jpeg"
            self.logo = @last_extension.logo
        else
          # if no image selected at vendor creation
          if self.logo != "none"
            # if there was an extension change
            @test = self.vendor_logo_file_name
            # if filename is purely non-latin then get the extension of the original filename manually
            if @test.scan(/^[a-zA-Z]/)
              self.logo = @test.split(".")[1]
            else
              self.logo = self.vendor_logo.url().split('?')[0].split('.')[1]
            end
          end  
        end
      end
    # if it is a new vendor
    # set logo attribute to something, doesn't matter what if no picture is uploaded, if picture is uploaded then picture's extension
    else
      if self.vendor_logo.url().split('?')[0] == "/vendor_logos/original/missing.png" && self.logo == "vendorlogos/logo.jpg"
        self.logo = "none"
      else
        @test = self.vendor_logo_file_name
        # if filename is purely non-latin then get the extension of the original filename manually
        if @test.scan(/^[a-zA-Z]/)
          self.logo = @test.split(".")[1]
        else
          self.logo = self.vendor_logo.url().split('?')[0].split('.')[1]
        end
      end
    end
  end

  #The previous logo is deleted, in case it has a different extension
  def delete_previous_logo
    if self.vendor_logo.url().split('?')[0] != "/vendor_logos/original/missing.png"
      begin
        @old_path = Rails.root.to_s+'/public/vendorlogos/'+self.id.to_s+"."+Vendor.find(self.id).logo.to_s
        if(File.exists?(@old_path))
          File.delete(@old_path)
        end
      end
    end
  end

  has_many :sites
  validates :vendor_name, presence: true, uniqueness: true, :length => { :in => 3..90 }
  validates :username, presence: true, uniqueness: true, :length => { :in => 6..45 }
  validates :password, presence:true, :format => { :with => /\A[a-zA-Z0-9.:;_+-@#\\$%]+\z/,
    :message => "Alphanumerical and some special characters only!" }
  validates_length_of :password, :minimum => 8, :maximum => 16, :message => "password must be between 8-16 characters", :if => :password
  validates_confirmation_of :password, :message => "should match confirmation", :if => :password
  validates :contact_person, presence: true, :format => { :with => /\A[a-zA-Z ]+\z/,
    :message => "Only letters allowed!" }, :length => { :in => 3..45 }
  validates :address, presence: true, :length => { :in => 3..45 }
  validates :email, presence: true, uniqueness: true, :format => { :with => /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\z/,
    :message => "Invalid email address format!" }, :length => { :in => 5..45 }
  validates :telephone, presence: true, uniqueness: true, :format => { :with =>  /\A[0-9+-]+\z/,
    :message => "Invalid telephone number format!" }, :length => { :in => 5..45 }
  validates :logo, :length => { :in => 0..100}
  validates_attachment :vendor_logo,
    :size => { :in => 0..512.kilobytes }
  # validates :terms_of_service, :acceptance => true

  after_destroy :ensure_an_admin_remains
  private
  def ensure_an_admin_remains
    if vendor.count.zero?
      raise "Can't delete last user!"
    end
  end
end