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
      session[:user] = {id: user.id, email: user.email, username: user.username, active: user.active }
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
    render :confirm_email
  end

  def login_facebook
    not_found
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

end
