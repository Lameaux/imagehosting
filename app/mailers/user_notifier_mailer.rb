class UserNotifierMailer < ApplicationMailer

  def send_signup_email(user)
    @user = user
    mail( :to => @user.email, :subject => 'pngif.com - confirm your email' )
  end

end
