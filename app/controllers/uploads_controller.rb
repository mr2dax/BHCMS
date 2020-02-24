class UploadsController < ApplicationController
  
  def index
    # fetching vendor and site from db to use in uploaded picture's params
    @vendor = Vendor.find(current_user)
    @site = session[:site_id]
    @uploads = Upload.find_all_by_site_id(@site)
    respond_to do |format|
      format.html
      format.json { render json: @uploads.map{|upload| upload.to_jq_upload } }
    end
  end

  def new
    @upload = Upload.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @upload }
    end
  end

  def create
    # getting the params of the uploaded picture
    @upload = Upload.new(params[:upload][:upload])
    # vendor and site id to store in db with picture params (received separately - paperclip)
    @upload[:vendor_id] = params[:vendor_id]
    @upload[:site_id] = params[:site_id]
    # default description
    @upload[:desc] = "Please edit the default description!"
    respond_to do |format|
      if @upload.save # save to db
        format.html {
          render :json => [@upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: [@upload.to_jq_upload].to_json, status: :created, location: @upload }
        # getting over the problem where paperclip had problems with non-latin characters
        # resolution: simply renaming the file, adding it's extension stored in the db, after upload if it didn't have an extension
        # querying the db for the params of the picture that just got uploaded
        @uploadtemp = Upload.find_by_id(@upload[:id])
        # rename the picture to
        @newpath = Rails.root.join("public/sites/" + @uploadtemp[:vendor_id].to_s + "/" + @uploadtemp[:site_id].to_s + "/res/" + @uploadtemp[:id].to_s + "_original." + @uploadtemp[:upload_file_name].to_s.split(".")[1])
        # rename the picture from (no extension)
        @oldpath = Rails.root.join("public/sites/" + @uploadtemp[:vendor_id].to_s + "/" + @uploadtemp[:site_id].to_s + "/res/" + @uploadtemp[:id].to_s + "_original")
        if File.exists?(@oldpath) # if no extension
          @ext = @uploadtemp[:upload_file_name] # extension e.g. jpg, jpeg or png
          File.rename(@oldpath,@newpath)
        end
      else
        format.html { render action: "new" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # to delete file from the filesystem
    require 'FileUtils'   
    @upload = Upload.find(params[:id])
    # remove picture file with original uploaded name having non-latin chars
    @del_path = Rails.root.join("public/sites/" + @upload[:vendor_id].to_s + "/" + @upload[:site_id].to_s + "/res/" + @upload[:id].to_s + "_original." + @upload[:upload_file_name].to_s.split(".")[1])
    if File.exist?(@del_path)
      FileUtils.rm(@del_path)
    end
    # remove from db (also removes file if it's filename is latin chars only)
    @upload.destroy
    respond_to do |format|
      format.html { redirect_to uploads_url }
      format.json { head :no_content }
    end
  end

  # update the description of the uploaded image after successful upload with ajax
  def update_desc
    @id = params[:id]
    @desc = params[:desc]
    @upload = Upload.find_by_id(@id)
    @upload[:desc] = @desc
    @upload.save
  end
end