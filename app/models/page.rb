class Page < ActiveRecord::Base
  attr_accessible :site_id, :template_id, :page_name, :language, :theme_id
  
  belongs_to :site
  has_one :template
  has_one :exported_page
  has_one :theme
  
  validates :template_id, presence:true
  validates :page_name, presence:true, :format => { :with => /\A[a-zA-Z0-9 _-]+\z/ }, :length => { :in => 1..45 }
  validates :language, presence:true
  validates :theme_id, presence:true
end