class Site < ActiveRecord::Base
  attr_accessible :id, :vendor_id, :landing_page_id, :site_name, :site_type, :latitude, :longitude, :site_logo, :logo, :description, :address, :telephone
  
  attr_accessor :site_logo_file_name
  attr_accessor :site_logo_content_type
  attr_accessor :site_logo_file_size
  attr_accessor :site_logo_updated_at
  
  has_attached_file :site_logo, :url => ":rails_root/public/sitelogos/:id.:extension",
    :path => ":rails_root/public/sitelogos/:id.:extension"
  validates_attachment_content_type :site_logo, :content_type => [ 'image/jpeg', 'image/jpg', 'image/png' ],
                                    :message => 'allowed extensions are: jpg, jpeg or png !'
  before_save   :edit_logo_path
  after_save    :rename_file
  before_update :delete_previous_logo
  # paperclip problem with japanese characters in filename => file has no extension after arriving to the server => granting extension from db
  def rename_file
    @old_path = Rails.root.to_s+'/public/sitelogos/'+self.id.to_s
    @new_path = Rails.root.to_s+'/public/sitelogos/'+self.id.to_s+"."+self.logo.to_s
      if(File.exists?(@old_path))
        File.rename(@old_path, @new_path)
    end
  end
  # needed if site logo's extension changes or if the site was created without a logo being uploaded at creation
  def edit_logo_path
    # check if not a new site
    if Site.exists?(self.id)
      begin
        # previous site logo's extension in the db
        @last_extension = Site.find_by_id(self.id)  
        # site_logo.url from paperclip (no image attached error message), self.logo from sites/_form.html (no image selected to be uploaded)
        if self.site_logo.url().split('?')[0] == "/site_logos/original/missing.png" && self.logo == "/sitelogos/logo.jpg"
            # if there was no image selected at edit (or landing page was updated) take the previous extension from db
            self.logo = @last_extension.logo
            # if there was a change in landing page or other single/multiple value updates then use the previous extension from db
        elsif self.site_logo.url().split('?')[0] == "/site_logos/original/missing.png" && self.logo == "jpg"
            self.logo = @last_extension.logo
        elsif self.site_logo.url().split('?')[0] == "/site_logos/original/missing.png" && self.logo == "png"
            self.logo = @last_extension.logo
        elsif self.site_logo.url().split('?')[0] == "/site_logos/original/missing.png" && self.logo == "jpeg"
            self.logo = @last_extension.logo
        else
          # if no image selected at site creation
          if self.logo != "none"
            # if there was an extension change
            @test = self.site_logo_file_name
            # if filename is purely non-latin then get the extension of the original filename manually
            if @test.scan(/^[a-zA-Z]/)
              self.logo = @test.split(".")[1]
            else
              self.logo = self.site_logo.url().split('?')[0].split('.')[1]
            end
          end
        end
      end
    # if it is a new site
    # set logo attribute to something, doesn't matter what if no picture is uploaded, if picture is uploaded then picture's extension
    else
      if self.site_logo.url().split('?')[0] == "/site_logos/original/missing.png" && self.logo == "/sitelogos/logo.jpg"
        self.logo = "none"
      else
        @test = self.site_logo_file_name
        # if filename is purely non-latin then get the extension of the original filename manually
        if @test.scan(/^[a-zA-Z]/)
          self.logo = @test.split(".")[1]
        else
          self.logo = self.site_logo.url().split('?')[0].split('.')[1]
        end
      end
    end
  end

  # The previous logo is deleted, in case it has a different extension
  def delete_previous_logo
    if self.site_logo.url().split('?')[0] != "/site_logos/original/missing.png"
      begin
        @old_path = Rails.root.to_s+'/public/sitelogos/'+self.id.to_s+"."+Site.find(self.id).logo.to_s
        if(File.exists?(@old_path))
          File.delete(@old_path)
        end
      end
    end
  end
  
  belongs_to :vendor
  has_many  :pages
  validates :site_name, presence:true, :format => { :with => /\A[a-zA-Z0-9.:;_+-@#\\$% ]+\z/,
    :message => "Alphanumerical and some special characters only!" }, :length => { :in => 1..45 }
  validates :site_type, presence:true, :format => { :with => /\A[0-9]+\z/ }, :length => { :in => 1..3 }
  validates :latitude, presence:true
  validates :longitude, presence:true
  validates :description, presence:true
  validates :telephone, :format => { :with => /\A[0-9+-]+\z/ }
  validates :logo, :length => { :in => 0..100}
  validates_attachment :site_logo,
    :size => { :in => 0..512.kilobytes }
end