class VendorsController < ApplicationController

  skip_before_filter :require_login, :only => [:index, :new, :create, :activate]
  
  def activate
    if (@vendor = Vendor.load_from_activation_token(params[:id]))
      @vendor.activate!
      redirect_to(login_path, :notice => 'Vendor account was successfully activated. Now you can log in.')
    else
      not_authenticated
    end
  end
  
# TODO
  def unlock
    @vendor = Vendor.load_from_unlock_token(params[:token])
    if @vendor
      @vendor.unlock!
      auto_login(@vendor)
      redirect_to profile_index_path, notice: "Your account has been unlocked !"
    else
      flash[:alert] = "Unlock token not found"
      not_authenticated
    end
  end

  def index
    # when user closes the browser and revisits the page he/she will be redirected to login page even though he/she is still logged in
    # fixing this by just checking if there is a user currently logged in (current_user)
    @vendor = current_user
    if @vendor
      redirect_to admin_url
    else
      redirect_to login_url
    end
  end

  def new
    @vendor = Vendor.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vendor }
    end
  end

  def create
    @vendor = Vendor.new(params[:vendor])
    respond_to do |format|
      if @vendor.save
        Dir::mkdir("public/sites/"+ @vendor.id.to_s)
        format.html { redirect_to login_url, notice: "Vendor #{@vendor.vendor_name} with username #{@vendor.username} has been successfully created. An activation email has been sent to #{@vendor.email}." }
        format.json { render json: @vendor, status: :created, location: @vendor }
      else
        format.html { render action: "new" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @vendor = Vendor.find(current_user)
  end

  def update
    @vendor = Vendor.find(current_user)
    respond_to do |format|
      if @vendor.update_attributes(params[:vendor])
        # make a directory with the newly created vendor's id if save to db was okay
        format.html { redirect_to admin_url, notice: "Vendor #{@vendor.username} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end
end