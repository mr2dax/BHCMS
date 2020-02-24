class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
    
  # request password reset.
  # you get here when the user entered his email in the reset password form and submitted it.
  def create 
    @vendor_email = Vendor.find_by_email(params[:email])
    @vendor_username = Vendor.find_by_username(params[:username])
    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    if (@vendor_email && @vendor_username)
      @vendor_email.deliver_reset_password_instructions!
    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.
      redirect_to(login_path, :notice => 'Instructions have been sent to your email.')
    else
      redirect_to(login_path, :notice => 'Incorrect username and/or email address.')
    end
  end
    
  # This is the reset password form.
  def edit
    @vendor = Vendor.load_from_reset_password_token(params[:id])
    @token = params[:id]
    not_authenticated unless @vendor
  end
      
  # This action fires when the user has sent the reset password form.
  def update
    @token = params[:token]
    @vendor = Vendor.load_from_reset_password_token(params[:token])
    not_authenticated unless @vendor
    # the next line makes the password confirmation validation work
    @vendor.password_confirmation = params[:vendor][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @vendor.change_password!(params[:vendor][:password])
      redirect_to(login_path, :notice => 'Password was successfully updated. You can log in now with your new password.')
    else
      render :action => "edit"
    end
  end
end