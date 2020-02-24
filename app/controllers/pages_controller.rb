class PagesController < ApplicationController
  before_filter :require_login # session security
  def manage # the meat of the application
    # get vendor's id from session helper
    @vendor = Vendor.find(current_user)
    # get all available templates (system and user-uploaded templates)
    @temp = Template.find(:all, :conditions => ["vendor_id = ? or vendor_id = ?", 0, current_user])
    # themes
    @themes = Theme.all
    # get site id from params received from admin view
    @siteid = params[:site_id]
    # put variable to session params to be sent to another controller for usage
    # this is a special case when the gallery is in an iframe in the manage view and has an individual mvc
    session[:site_id] = @siteid
    # setting the landing page
    # get landing page of site
    @site = Site.find_by_id(@siteid)
    @landingpage = @site.landing_page_id
    # get all pages by current site's id
    @pages  = Page.find_all_by_site_id(@siteid)
    # count existing page entries in db
    @pages_count = @pages.count
    # if there is no landing page defined in the db (newly created site or deleted all pages)
    if @landingpage == 0 && @pages_count == 0
    # default values
        @page = Page.new
        @page.site_id = @siteid
        @page.template_id = 1
        @page.page_name = "PAGE"
        @page.language = "en"
        @page.theme_id = 1
        if @page.save
            # construct the path for the page html file and set the landing page id to the newly created page in db.sites
            @page_path = 'public/sites/' + @vendor.id.to_s + "/" + @siteid.to_s + "/" + @page.id.to_s + '.html' 
            File.open(@page_path, "w+") do |f| # save to file
              f.write("<html><head></head><body bgcolor='#E6E6FA'>Page " + @page.id.to_s + "</body></html>") 
            end
            @site[:landing_page_id] = @page.id
            @site.save # save to db
        end
        @landingpage = @page.id # set landing page to the current, newly created page's id to use in manage view
    else
      @page = Page.find(@landingpage)
    end
    # refreshing pages list, plays a role when a new page was created (first time for site to enter manage view or user deleted all of the pages of the site and reentered manage view)
    @pages  = Page.find_all_by_site_id(@siteid)
    # restricts vendors from accessing other vendors' sites at manage
    @sitesvendor = Site.where("vendor_id = " + @vendor[:id].to_s + " and id = " + params[:site_id].to_s)
    if @sitesvendor.exists?
      respond_to do |format|
        format.html
        format.json { render json: @pages }
      end
    else
      redirect_to admin_path
    end
  end

  # Create a new default page
  def new_page
    @vendor = Vendor.find(current_user)
    @page = Page.new
    @page.site_id = params[:site_id]
    @page.template_id = 1
    @page.page_name = "PAGE"
    @page.language = "en"
    @page.theme_id = 1    
    respond_to do |format|
      if @page.save
        #Construct the path for the destination page file
        @page_path = 'public/sites/' + @vendor.id.to_s + "/" + @page.site_id.to_s + "/" + @page.id.to_s + '.html' 
        File.open(@page_path, "w+") do |f|
         f.write("<html><head></head><body bgcolor='#E6E6FA'>Page " + @page.id.to_s + "</body></html>") 
        end
        #redirect to the view and render the partial
        format.html { redirect_to page_manage_path}
        format.js
        format.json { render json: @page, 
        status: :created, location: @page }
      else 
        format.html { render action: "new" }
        format.json { render json: @page.errors,
        status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # values passed from the view when user selects a page and clicks delete
    @vendorid = params[:vendor_id].to_s # deleted page vendor id
    @siteid   = params[:site_id].to_s   # deleted page site id
    @pageid  = params[:page_id].to_s   # deleted page id
    # if any page was selected
    if @pageid != "-1"
      begin
        # find page to delete and remove record from db
        @page = Page.find(@pageid)
        @page.destroy
        # setting the path for the file to delete from the server
        @target  = Rails.root.join('public', 'sites', @vendorid , @siteid , @pageid + '.html' )
        # delete file from server
        File.unlink(@target)
        respond_to do |format|
          #format.html { redirect_to @siteid }
          format.json { render json: :ok}
        end
      end
    # if no page was selected do nothing
    else
      respond_to do |format|
        format.html { redirect_to @siteid }
        format.json { head :no_content }
      end
    end
  end

  def save_page
    # values passed from the view when user selects a page and clicks save
    @content  = params[:frame_content].to_s # saved page content
    @vendorid = params[:vendor_id].to_s     # saved page vendor id
    @siteid   = params[:site_id].to_s       # saved page site id
    @pageid   = params[:page_id].to_s       # saved page id
    @title    = params[:title].to_s         # saved page title
    # setting the path for the file to save to server
    @target  = Rails.root.join('public', 'sites', @vendorid , @siteid , @pageid + '.html' )
    # if any page was selected
    if @pageid != "-1"
      begin
        # open existing file and write content, saved on server
        File.open(@target, "w+") do |f|
          f.write(@content)
        end
        @page = Page.find_by_id(@pageid)
        @page[:page_name] = @title
        @page.save
        respond_to do |format|
          format.json { render json: :ok }
        end
      end
    # if no page was selected do nothing
    else
      respond_to do |format|
        format.html { redirect_to @siteid }
        format.json { head "Error, no page selected" }
      end
    end
  end
  
  def set_landing
    # values passed from the view when user selects a page and clicks set as landing page
    @siteid   = params[:site_id].to_s       # saved page site id
    @pageid   = params[:page_id].to_s       # saved page id
    # setting the path for the file to save to server
    # if any page was selected
    if @pageid != "-1"
      begin
         @site = Site.find_by_id(@siteid)
         @site[:landing_page_id] = @pageid
         respond_to do |format|
           if @site.save
              format.json { render json: :ok }
           end
      end
    end
    # if no page was selected do nothing
    else
      respond_to do |format|
        format.html { redirect_to @siteid }
        format.json { head "Error, no page selected" }
      end
    end
  end
  
  def export_page
    # fileutils module to delete archive and to copy fontFaces.css
    require 'fileutils'
    # needed for rubyzip
    require 'rubygems'
    require 'zip/zip'
    # parsing html and css
    require 'nokogiri'
    require 'css_parser'
    # values passed from the view when user selects a page and clicks the export page button
    @vendorid = params[:vendor_id].to_s   # export page vendor id from client via ajax
    @siteid = params[:site_id].to_s   # export page site id from client via ajax
    @pageid   = params[:page_id].to_s       # export page page id from client via ajax
    # needed for correct pathing of the files and directories, because of site's ids can be 1,2,3 or 4 digits (or even more)
    @folder = Rails.root.join('public', 'sites', @vendorid , @siteid)
    @folder_cf = Rails.root.join('public', 'assets', 'ContentFlow')
    @folder_ffc = Rails.root.join('public', 'sites', @vendorid)
    @folder_font = Rails.root.join('public', 'assets', 'fontFaces')
    @folder_main_ffc = Rails.root.join('public', 'stylesheets') # main fontFaces.css (file to copy)
    # get the font
    @font_used = ""
    # default image used
    @default_image_used = false
    # is a contentflow type of document?
    @cf_doc = false
    # used images list
    @images_used = Array.new()
    # get the page itself
    the_page = Dir.glob(@folder.to_s + "/" + @pageid + ".html")
    # the above fetches an array with one element, unable to convert it directly to string
    # so the below cycle is needed to extract that one page path
    the_page.each do |page|
      # carve out the font-family from the page
      pagecontent = File.read(page)
      pagecontent.to_s
      # if page uses no font-family
      if pagecontent.index("font-family:")
        start_of_fontfamily = pagecontent.index("font-family:")
        @font_used = pagecontent[start_of_fontfamily+13..start_of_fontfamily+35].split(";")[0]
      else
        @font_used = ""
      end
      # if document has contentflow elements
      if pagecontent.index("contentflow.css")  || pagecontent.index("contentflow.js")
        @cf_doc = true
      end
      # get list of pics used in document
      f = File.open(page)
      doc = Nokogiri::HTML(f)
      f.close
      doc.css("img").each do |image|
        image_name = image.to_s
        # give them relative path
        # if default image (leave out other contentflow pics)
        if image_name.index("lightboxImage") || image_name.index("loadingImage") || image_name.index("closeButton")
          
        elsif image_name.index("defaultImage.png")
          @default_image_used = true
        else
        image_name = image_name.split("/res/")[1].split('"')[0]
          if not @images_used.include?(image_name)
            @images_used << image_name
          end
        end
      end
    end
    if @default_image_used == true
      @images_used << "defaultImage.png"
    end
    # array of the paths and filenames to be included in the compressed archive
    input_filenames = 
      Dir.glob(@folder.to_s + "/" + @pageid + ".html") + # page
      Dir.glob(@folder.to_s + "/styles/*") + # css TODO
      Dir.glob(@folder.to_s + "/scripts/*") + # js TODO
      Dir.glob(@folder_font.to_s + "/" + @font_used + "/*") # font
    # used image list to include in zip file
    @images_used.each do |imagename|
      if imagename.index("defaultImage.png")
        imagepath = Dir.glob(Rails.root.join("public" , "images" , "defaultImage.png")) # default picture
        input_filenames = input_filenames + imagepath
      else
        imagepath = Dir.glob(@folder.to_s + "/res/" + imagename) # picture
        input_filenames = input_filenames + imagepath
      end
    end
    # if no font was used on page
    if @font_used != "" # current default
      fontfaces_css = @folder_ffc.to_s + '/fontFaces.css' # fonts css
      input_filenames << fontfaces_css
    end
    if @cf_doc
      contentflow_stuff = 
        Dir.glob(@folder_cf.to_s + "/*")
      input_filenames = input_filenames + contentflow_stuff
      contentflow_stuff = Dir.glob(@folder_cf.to_s + "/img/*")
      input_filenames = input_filenames + contentflow_stuff
      contentflow_stuff = Dir.glob(@folder_cf.to_s + "/lightbox/*")
      input_filenames = input_filenames + contentflow_stuff
      contentflow_stuff = Dir.glob(@folder_cf.to_s + "/pics/*")
      input_filenames = input_filenames + contentflow_stuff
    end
    # saved as sites/vendor_id/site_id_page_id.zip
    zipfile_name = @folder.to_s + '_'+ @pageid + '.zip'
    # if archive already exist with this name
    if File.exists?(zipfile_name)
      FileUtils.rm(zipfile_name)
    end
    # zippy cycle
    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      input_filenames.each do |fullfilepath|
        # adjusting filenames in archive
        # image or page
        if (fullfilepath.index('.html') || fullfilepath.index('_original.') ) && !fullfilepath.index('ContentFlow')
          filename = fullfilepath[(@folder.to_s.length + 1 )..fullfilepath.length]
        # default image
        elsif fullfilepath.index('defaultImage.png')
          filename = "defaultImage.png"
        # contentflow stuff
        elsif fullfilepath.index('ContentFlow')
          filename = "scripts/ContentFlow/" + fullfilepath[(@folder_cf.to_s.length + 1 )..fullfilepath.length]
        # fontfaces.css
        elsif fullfilepath.index('/fontFaces.css')
          filename = fullfilepath[(@folder_ffc.to_s.length + 1 )..fullfilepath.length]
        # fonts
        elsif fullfilepath.index('/fontFaces/')
          filename = "font/" + fullfilepath[(@folder_font.to_s.length + 1 )..fullfilepath.length]
        end
        # if file is a page then parse html with nokogiri
        if fullfilepath.index('.html') && fullfilepath.index('sites')
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # find all image tags
          doc.css("img").each do |image|
            image_name = image.to_s
            # give them relative path
            # if default image
            if image_name.index("defaultImage.png")
              image_name = "./defaultImage.png"
            else
              image_name = "./res/" + image_name.split("/res/")[1].split('"')[0]
            end
            image.attributes["src"].value = image_name
          end
          # write changed paths of images to file
          File.open(fullfilepath,'w') {|o| doc.write_html_to o}
          # fontFaces path adjustment in html document
          text = File.read(fullfilepath)
          replace = text.gsub!("/stylesheets/", "")
          File.open(fullfilepath, "w") { |file| file.puts replace }
          # contentflow path adjustments in html document
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # check if document has canvas (contentflow)
          checker = doc.to_s
          if checker.index("contentflow.css") || checker.index("contentflow.js")
            text = File.read(fullfilepath)
            replace = text.gsub!("/assets/", "./scripts/")
            File.open(fullfilepath, "w") { |file| file.puts replace }
          end
        end
        # if file is the font css
        if fullfilepath.index('fontFaces.css')
          path_of_main_ffc = @folder_main_ffc.to_s + "/fontFaces.css"
          FileUtils.cp path_of_main_ffc, fullfilepath
          text = File.read(fullfilepath)
          replace = text.gsub!("/assets/fontFaces", "./font")
          File.open(fullfilepath, "w") { |file| file.puts replace }
        end
        # Two arguments: (filename, fullfilepath)
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, fullfilepath)
      end
    end
    # send file back at browser
    send_file(zipfile_name, :disposition => 'attachment')
    # setting everything back to as it was
    input_filenames.each do |fullfilepath|
       # if file is a page then parse html with nokogiri
        if fullfilepath.index('.html') && fullfilepath.index('sites')
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # find all image tags, if it's a doc with canvas (contentflow) do nothing
          doc.css("img").each do |image|
            image_name = image.to_s
            # give them absolute path
            if image_name.index("defaultImage.png") # if default image
              image_name = "/images/defaultImage.png"
            else
              image_name = "/sites/" + @vendorid + "/" +  @siteid + "/res/" + image_name.split("res/")[1]
              image_name = image_name.split("\"")[0]
            end
            image.attributes["src"].value = image_name
          end
          # write changed paths to file
          File.open(fullfilepath,'w') {|o| doc.write_html_to o}
          # fontFaces path adjustment
          text = File.read(fullfilepath)
          replace = text.gsub!("<link rel=\"stylesheet\" type=\"text/css\" href=\"fontFaces.css\" media=\"screen\">", "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheets/fontFaces.css\" media=\"screen\">")
          File.open(fullfilepath, "w") { |file| file.puts replace }
          # ContentFlow path adjustments
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # check if document has canvas (contentflow)
          checker = doc.to_s
          if checker.index("contentflow.css")  || checker.index("contentflow.js")
            text = File.read(fullfilepath)
            replace = text.gsub!("./scripts/ContentFlow/", "/assets/ContentFlow/")
            File.open(fullfilepath, "w") { |file| file.puts replace }
          end
        end
        # if file is the font css
        if fullfilepath.index('fontFaces.css')
          # delete temporary fontFaces.css
          if File.exists?(fullfilepath)
            FileUtils.rm(fullfilepath)
          end
        end
    end
  end
  
  def export_all
    # fileutils module to delete archive
    require 'fileutils'
    # needed for rubyzip
    require 'rubygems'
    require 'zip/zip'
    # parsing html and css
    require 'nokogiri'
    require 'css_parser' 
    # values passed from the view when user clicks export all
    @vendorid = params[:vendor_id].to_s   # export all vendor id from client via ajax
    @siteid = params[:site_id].to_s   # export all site id from client via ajax
    # needed for correct pathing of the files and directories, because of site's ids can be 1,2,3 or 4 digits (or even more)
    @folder = Rails.root.join('public', 'sites', @vendorid , @siteid)
    @folder_cf = Rails.root.join('public', 'assets', 'ContentFlow')
    @folder_ffc = Rails.root.join('public', 'sites', @vendorid)
    @folder_font = Rails.root.join('public', 'assets', 'fontFaces')
    @folder_main_ffc = Rails.root.join('public', 'stylesheets') # main fontFaces.css (file to copy)
    # get fonts used
    @fonts_used = Array.new()
    # is a contentflow type of document?
    @cf_doc = Array.new()
    # default image used variable initialization
    @def_image_used = false
    # list of all pages of site
    pages_filenames = Dir.glob(@folder.to_s + "/*.html")
    pages_filenames.each do |page_filename|
      # carve out the font-family fromÅ@each and every page
      pagecontent = File.read(page_filename)
      pagecontent.to_s
      # if all pages use default fonts (no font-family string to be found in whole document)
      if pagecontent.index("font-family:")
        start_of_fontfamily = pagecontent.index("font-family:")
        if not @fonts_used.include?(pagecontent[start_of_fontfamily+13..start_of_fontfamily+35].split(";")[0])
          @fonts_used << pagecontent[start_of_fontfamily+13..start_of_fontfamily+35].split(";")[0]
        end
      end
      # default picture used? than set boolean to true
      if pagecontent.index("defaultImage.png")
        @def_image_used = true
      end
      # if document has contentflow elements
      if pagecontent.index("contentflow.css")  || pagecontent.index("contentflow.js")
        @cf_doc << true
      else
        @cf_doc << false
      end
    end
    # array of the paths and filenames to be included in the compressed archive
    input_filenames = 
      Dir.glob(@folder.to_s + "/*") + # pages
      Dir.glob(@folder.to_s + "/styles/*") + # css TODO
      Dir.glob(@folder.to_s + "/scripts/*") + # js TODO
      Dir.glob(@folder.to_s + "/res/*_original.*") # all pictures of site
    # fonts, if no fonts were used on any of the pages
    @fonts_used.each do |font|
      fontpath = Dir.glob(@folder_font.to_s + "/" + font + "/" + font + ".ttf")
      input_filenames = input_filenames + fontpath
      fontpath = Dir.glob(@folder_font.to_s + "/" + font + "/" + font + ".eot")
      input_filenames = input_filenames + fontpath
    end  
    if @fonts_used != "" # current default
      fontfaces_css = @folder_ffc.to_s + '/fontFaces.css' # fonts css
      input_filenames << fontfaces_css
    end
    if @cf_doc.include? true # has contentflow elements?
      contentflow_stuff = Dir.glob(@folder_cf.to_s + "/*")
      input_filenames = input_filenames + contentflow_stuff
      contentflow_stuff = Dir.glob(@folder_cf.to_s + "/img/*")
      input_filenames = input_filenames + contentflow_stuff
      contentflow_stuff = Dir.glob(@folder_cf.to_s + "/lightbox/*")
      input_filenames = input_filenames + contentflow_stuff
      contentflow_stuff = Dir.glob(@folder_cf.to_s + "/pics/*")
      input_filenames = input_filenames + contentflow_stuff
    end
    # if any of the pages use the default image (no pic selected for a contentflow picture element either)
    if @def_image_used
      imagepath = Dir.glob(Rails.root.join("public" , "images" , "defaultImage.png")) # default picture
      input_filenames = input_filenames + imagepath
    end
    # saved as sites/vendor_id/site_id_all.zip
    zipfile_name = @folder.to_s + '_all.zip'
    # if archive already exist with this name
    if File.exists?(zipfile_name)
      FileUtils.rm(zipfile_name)
    end
    # zippy cycle
    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      input_filenames.each do |fullfilepath|
        # adjusting filenames in archive
        # image or page
        if (fullfilepath.index('.html') || fullfilepath.index('_original.') ) && !fullfilepath.index('ContentFlow')
          filename = fullfilepath[(@folder.to_s.length + 1 )..fullfilepath.length]
        # default image
        elsif fullfilepath.index('defaultImage.png')
          filename = "defaultImage.png"
        # contentflow stuff
        elsif fullfilepath.index('ContentFlow')
          filename = "scripts/ContentFlow/" + fullfilepath[(@folder_cf.to_s.length + 1 )..fullfilepath.length]
        # fontfaces.css
        elsif fullfilepath.index('/fontFaces.css')
          filename = fullfilepath[(@folder_ffc.to_s.length + 1 )..fullfilepath.length]
        # fonts
        elsif fullfilepath.index('/fontFaces/')
          filename = "fonts/" + fullfilepath[(@folder_font.to_s.length + 1 )..fullfilepath.length]
        end
        # if file is a page then parse html with nokogiri
        if fullfilepath.index('.html') && fullfilepath.index('sites')
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # find all image tags       
          doc.css("img").each do |image|
            image_name = image.to_s
            # give them relative path
            # if default image
            if image_name.index("defaultImage.png") || image_name.index("#") # leave out the contentflow elements which don't have images selected
              image_name = "./defaultImage.png"
            else
              image_name = "./res/" + image_name.split("/res/")[1].split('"')[0]
            end
            image.attributes["src"].value = image_name
          end
          # write changed paths of images to file
          File.open(fullfilepath,'w') {|o| doc.write_html_to o}
          # fontFaces path adjustment in html document
          text = File.read(fullfilepath)
          replace = text.gsub!("/stylesheets/", "")
          File.open(fullfilepath, "w") { |file| file.puts replace }
          # contentflow path adjustments in html document
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # check if document is a canvas doc
          checker = doc.to_s
          if checker.index("contentflow.css") || checker.index("contentflow.js")
            text = File.read(fullfilepath)
            replace = text.gsub!("/assets/", "./scripts/")
            File.open(fullfilepath, "w") { |file| file.puts replace }
          end
        end
        # if file is the font css
        if fullfilepath.index('fontFaces.css')        
          path_of_main_ffc = @folder_main_ffc.to_s + "/fontFaces.css"
          FileUtils.cp path_of_main_ffc, fullfilepath
          text = File.read(fullfilepath)
          replace = text.gsub!("/assets/fontFaces", "./fonts")
          File.open(fullfilepath, "w") { |file| file.puts replace }
        end
        # Two arguments: (filename, fullfilepath)
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, fullfilepath)
      end
    end
    # send file back at browser
    send_file(zipfile_name, :disposition => 'attachment')
    # setting everything back to as it was
    input_filenames.each do |fullfilepath|
       # if file is a page then parse html with nokogiri
        if fullfilepath.index('.html') && fullfilepath.index('sites')
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # find all image tags, if it's a doc with canvas do nothing
          doc.css("img").each do |image|
            image_name = image.to_s
            # give them absolute path
            if image_name.index("defaultImage.png") # if default image
              image_name = "/images/defaultImage.png"
            else
              image_name = "/sites/" + @vendorid + "/" +  @siteid + "/res/" + image_name.split("res/")[1]
              image_name = image_name.split("\"")[0]
            end
            image.attributes["src"].value = image_name
          end
          # write changed paths to file
          File.open(fullfilepath,'w') {|o| doc.write_html_to o}
          # fontFaces path adjustment
          text = File.read(fullfilepath)
          replace = text.gsub!("<link rel=\"stylesheet\" type=\"text/css\" href=\"fontFaces.css\" media=\"screen\">", "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheets/fontFaces.css\" media=\"screen\">")
          File.open(fullfilepath, "w") { |file| file.puts replace }
          # ContentFlow path adjustments
          f = File.open(fullfilepath)
          doc = Nokogiri::HTML(f)
          f.close
          # check if document is a canvas doc
          checker = doc.to_s
          if checker.index("contentflow.css") || checker.index("contentflow.js")
            text = File.read(fullfilepath)
            replace = text.gsub!("./scripts/ContentFlow/", "/assets/ContentFlow/")
            File.open(fullfilepath, "w") { |file| file.puts replace }
          end
        end
        # if file is the font css
        if fullfilepath.index('fontFaces.css')
          # delete temporary fontFaces.css
          if File.exists?(fullfilepath)
            FileUtils.rm(fullfilepath)
          end
        end
    end
  end
  
  def refresh_pages_list
    @siteid = params[:site_id]
    # getting pages for site
    @pages  = Page.find_all_by_site_id(@siteid)
    # new array to store id and name of each page per site
    @pag = Array.new()
    # generating the array dynamically
    @pages.each do |page|
      @pag << page[:id]
      @pag << page[:page_name]
    end
    respond_to do |format|
      # sending the updated array back
      format.json { render :json => @pag }
    end
  end
  
  def refresh_resources_list
    @siteid = params[:site_id]
    # getting pictures for site
    @resources  = Upload.find_all_by_site_id(@siteid)
    # new array to store id and desc of each picture per site
    @res = Array.new()
    # generating the array dynamically
    @resources.each do |resource|
      @res << resource[:id]
      @res << resource[:desc]
      @res << resource[:upload_file_name].split('.')[1]
    end
    respond_to do |format|
      # sending the updated array back
      format.json { render :json => @res }
    end
  end
end