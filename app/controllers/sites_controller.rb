  class SitesController < ApplicationController

  before_filter :require_login

  def index
    @sites = Site.all
    respond_to do |format|
      format.html
      format.json { render json: @sites }
    end
  end
  
  def show
    # restricts vendors from accessing other vendors' sites at admin
    begin
    @site = Site.find(params[:id])
    # get the correct site type
    @site[:site_type] = Bhcms::Application::SITE_CAT[@site[:site_type].to_i-1][1]
      if @site[:vendor_id] == current_user.id
        respond_to do |format|
          format.html
          format.json { render json: @site }
        end
      else
        redirect_to admin_path
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_path
    end
  end

  def new
    @site = Site.new
    respond_to do |format|
      format.html
      format.json { render json: @site }
    end
  end

  def edit
    @site = Site.find(params[:id])
  end

  def create
    @site = Site.new(params[:site])
    @site.vendor_id = current_user.id
    @site.landing_page_id = 0
    @pages = Page.find_all_by_site_id(@site[:id])
    respond_to do |format|
      if @site.save
        # make a directory with the newly created site's id if save to db was okay
        Dir::mkdir("public/sites/"+ @site.vendor_id.to_s + "/" + @site.id.to_s)
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render json: @site, status: :created, location: @site }
      else
        format.html { render action: "new" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @site = Site.find(params[:id])
    # set the landing page appropriately on updating the site
    if @site[:landing_page_id].nil? || @site[:landing_page_id] == "" || @site[:landing_page_id] == 0
      params[:site][:landing_page_id] = 0
    end
    respond_to do |format|
      if @site.update_attributes(params[:site])
        format.html { redirect_to admin_url, notice: 'Site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # fileutils module for deleting directories recursively
    require 'fileutils'
    @site = Site.find(params[:id])
    # path of the directory to delete
    @dir_path = "public/sites/"+ @site.vendor_id.to_s + "/" + @site.id.to_s
    # if existent and is a directory then delete recursively (delete pages, pics etc.)
    if File.exists?(@dir_path) && File.directory?(@dir_path) 
      FileUtils.rm_rf("public/sites/"+ @site.vendor_id.to_s + "/" + @site.id.to_s)   
    end
    # path of the site's picture to delete
    @pic_path = "public/sitelogos/" + @site.id.to_s + "." + @site.logo.to_s
    puts @pic_path
    if File.exists?(@pic_path)
      FileUtils.rm(@pic_path)   
    end
    # delete entry from db
    @site.destroy
    respond_to do |format|
      format.html { redirect_to admin_url }
      format.json { head :no_content }
    end
  end
end