class VendorSessionsController < ApplicationController

  skip_before_filter :require_login, :except => [:destroy]

  def new
    @vendor = Vendor.new
  end
  
  def create
    # session check (sorcery)
    if (Vendor.scoped_by_username(params[:username]).exists?)
      @temp = Vendor.find_by_username(params[:username])
      @active = @temp[:activation_state]
      @lock = @temp[:failed_logins_count]
      if @active == "active"
         if @lock.to_i >= 2
           @error = "You are locked out! Gomen..."
         else
           @error = "Password incorrect! " + (2-@lock.to_i).to_s + " attempts remaining. Ganbatte ne!"
         end
      else
        @error = "Please activate your account first!"
      end
    else
      @error = "Username doesn't exist!"
    end
    respond_to do |format|
      if ((@vendor = login(params[:username],params[:password])) && ((params[:username] != "") || (params[:password] != "")))
        format.html { redirect_to admin_path }
        format.xml { render :xml => @vendor, :status => :created, :location => @vendor }
      else
        format.html { flash.now[:alert] = @error ; render :action => "new" }
        format.xml { render :xml => @vendor.errors, :status => :unprocessable_entity }
      end
    end
  end
    
  def destroy
    logout
    redirect_to(:vendors, :notice => 'Logged out!')
  end
end
