class Template < ActiveRecord::Base
  attr_accessible :file_path, :description, :vendor_id, :temp_file
  
  # template upload variables
  attr_accessor :temp_file_file_name
  attr_accessor :temp_file_content_type
  attr_accessor :temp_file_file_size
  attr_accessor :temp_file_updated_at
  
  # to be able to use vendor_id in url and path (same trick as with resources)
  include Rails.application.routes.url_helpers

  Paperclip.interpolates :vendor_id do |attachment, style|
    attachment.instance.vendor_id
  end
  # path and url to save template
  has_attached_file :temp_file, :url => ":rails_root/public/templates/:vendor_id/:id.:extension",
    :path => ":rails_root/public/templates/:vendor_id/:id.:extension"
    
  belongs_to :page
  
  validates :description, presence:true
  # uploaded file size < 0,5 Mb and file extension html and htm only
  validates_attachment :temp_file, :presence => true,
    :size => { :in => 0..512.kilobytes }
  validates_format_of :temp_file_file_name, :with => %r{\.(html)$}i
end
