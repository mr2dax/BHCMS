class Theme < ActiveRecord::Base
  attr_accessible :id, :bg_color, :main_text_color, :normal_text_color, :button_color
  
  belongs_to :page
  
  validates :bg_color, presence:true
  validates :main_text_color, presence:true
  validates :normal_text_color, presence:true
  validates :button_color, presence:true
end
