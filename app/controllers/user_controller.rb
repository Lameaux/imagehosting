class UserController < ApplicationController

  def login
    @page.section = 'login'
    @page.title = "Log in to #{@page.site_name}"
    render :login
  end

  def login_post
    @page.section = 'login'

    user = User.find_by_email(params[:username_email]) || User.find_by_username(params[:username_email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:user] = { id: user.id, email: user.email, username: user.username, active: user.active }
      redirect_to '/'
      # active?
    else
      @form_username_email = params[:username_email]
      render :login
    end
  end

  def logout
    session[:user] = nil
    session[:user_id] = SecureRandom.uuid
    session[:my_images] = nil
    redirect_to '/'
  end

  def register
    @page.section = 'register'
    @page.title = "Register on #{@page.site_name}"

    @user = User.new

    render :register
  end

  def register_post
    @user = User.new(user_params)
    @user.id = session[:user_id]
    @user.activation_code = SecureRandom.uuid
    if @user.save
      session[:user] = { id: @user.id, email: @user.email, username: @user.username, active: @user.active }
      UserNotifierMailer.send_signup_email(@user).deliver
      redirect_to '/confirm-email'
    else
      render :register
    end
  end

  def reset_password
    @page.section = 'reset-password'
    @page.title = "Reset password on #{@page.site_name}"
    render :reset_password
  end

  def change_password
    render :change_password
  end

  def confirm_email
    @page.section = 'confirm-email'
    @page.title = "Confirm Email on #{@page.site_name}"
    render :confirm_email
  end

  def confirm_email_ok
    @page.section = 'confirm-email'
    @page.title = "Account activated on #{@page.site_name}"

    @user = User.find_by(activation_code: ShortUUID.expand(params[:activation_code]), active: 0)
    unless @user
      redirect_to '/'
      return
    end

    @user.update!(active: 1)
    session[:user]['active'] = 1

    render :confirm_email_ok
  end

  def login_facebook
    not_found
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

end
