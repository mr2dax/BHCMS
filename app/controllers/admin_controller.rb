class AdminController < ApplicationController

  before_filter :require_login
  
  def index
    @vendor = Vendor.find(current_user)
    @sites = Site.find_all_by_vendor_id(current_user)
    @sites.each do |site|
      # get the correct site type
      site[:site_type] = Bhcms::Application::SITE_CAT[site[:site_type].to_i-1][1]
    end
    respond_to do |format|
      format.html
      format.json { render json: @sites }
    end
  end
end