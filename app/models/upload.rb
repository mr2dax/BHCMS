class Upload < ActiveRecord::Base
  attr_accessible :upload, :vendor_id, :site_id, :desc
  # resizing prohibits the uploading of pictures with japanese names, so it is disabled for now
  has_attached_file :upload, #:styles => { :thumbnail => "100x100" },
    :path => "public/sites/:vendor_id/:site_id/res/:id_:style.:extension",
    :url => "/sites/:vendor_id/:site_id/res/:id_:style.:extension"

  # helpers for picture paths
  include Rails.application.routes.url_helpers
  # including vendor_id and site_id in paperclip json
  Paperclip.interpolates :vendor_id do |attachment, style|
    attachment.instance.vendor_id
  end
  Paperclip.interpolates :site_id do |attachment, style|
    attachment.instance.site_id
  end
  # the json attributes
  def to_jq_upload
    {
      "id" => read_attribute(:id),
      "vendor" => read_attribute(:vendor_id),
      "site" => read_attribute(:site_id),
      "name" => read_attribute(:upload_file_name),
      "desc" => read_attribute(:desc),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      "thumbnail_url" => upload.url(:thumbnail),
      "delete_url" => upload_path(self),
      "delete_type" => "DELETE" 
    }
  end
  validates_attachment :upload,
    :size => { :in => 0..512.kilobytes }
  validates_attachment_content_type :upload, :content_type => [ 'image/jpeg', 'image/jpg', 'image/png' ],
                                    :message => 'allowed extensions are: jpg, jpeg or png !'
end