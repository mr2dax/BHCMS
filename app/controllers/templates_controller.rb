class TemplatesController < ApplicationController

  before_filter :require_login
  
  def index
    # find all system templates and user templates of currently logged in user
    @templates = Template.find(:all, :conditions => ["vendor_id = ? or vendor_id = ?", 0, current_user]) 
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @templates }
    end
  end

  def show
    @template = Template.find(params[:id])
    # restricts users from viewing templates of other users and system templates
    if @template[:vendor_id] == current_user.id || @template[:vendor_id] == 0
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

  def new
    @template = Template.new
    respond_to do |format|
      format.html
      format.json { render json: @template }
    end
  end

  def edit
    @template = Template.find(params[:id])
    @action = "edit"
    # restricts users from editing templates of other users and system templates
    if @template[:vendor_id] == current_user.id
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

  def create
    @template = Template.new(params[:template])
    @template[:vendor_id] = current_user.id
    # just to have something written to the column of file_path in the db beforehand, otherwise it will return an error: cannot be nil
    @template[:file_path] = ""
    respond_to do |format|
      if @template.save
        format.html { redirect_to templates_url, notice: 'Template was successfully created.' }
        format.json { render json: @template, status: :created, location: @template }
      else
        format.html { render action: "new" }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
    # "callback" function, as the id was not available before saving the actual entry to the db
    @template[:file_path] = "/" + 'templates'+ "/" + @template[:vendor_id].to_s + "/" + @template[:id].to_s + '.html'
    @template.save
  end

  def update
    @template = Template.find(params[:id])
    respond_to do |format|
      if @template.update_attributes(params[:template])
        format.html { redirect_to @template, notice: 'Template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    require 'fileutils'
    # vendor id for deletion path
    @vendor = Vendor.find(current_user)
    # get the template to be deleted
    @template = Template.find(params[:id])
    # get the file path from the db
    @file_path = @template.file_path
    # construct the path with rails root (bit buggy imho) and delete if exists
    @template_path = Rails.root.join('public', '')
    @template_path = @template_path.to_s + @file_path.to_s
    if File.exists?(@template_path)
      FileUtils.rm(@template_path)
    end
    # delete entry from db
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_url }
      format.json { head :no_content }
    end
  end
end