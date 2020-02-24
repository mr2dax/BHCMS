class VendorMailer < ActionMailer::Base
  default from: "no-reply@baitalhikma.co.jp"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.vendor_mailer.activation_needed_email.subject
  #
  def activation_needed_email(vendor)
    @vendor = vendor
    @url  = "http://127.0.0.1:3000/vendors/#{vendor.activation_token}/activate"
    mail(:to => vendor.email,
       :subject => "Baitalhikma.co.jp - Please activate your vendor account")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.vendor_mailer.activation_success_email.subject
  #
  # not needed for now
  def activation_success_email(vendor)
    @vendor = vendor
    @url  = "http://127.0.0.1:3000/login"
    mail(:to => vendor.email,
        :subject => "Baitalhikma.co.jp - Your account is now activated")
  end

  def reset_password_email(vendor)
    @vendor = vendor
    @url  = "http://127.0.0.1:3000/password_resets/#{vendor.reset_password_token}/edit"
    mail(:to => vendor.email,
       :subject => "Baitalhikma.co.jp - Your password has been reset")
  end
  def send_unlock_token_email(vendor)
    @vendor = vendor
    @url = "http://127.0.0.1:3000/vendors/#{vendor.unlock_token}/unlock"
    mail(to: vendor.email, subject: "Your account has been locked due to many wrong logins")
  end
end
