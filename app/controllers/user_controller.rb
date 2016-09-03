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

  def reset_password_form
    @page.section = 'reset-password'
    @page.title = "Reset password on #{@page.site_name}"

    @user = User.find_by(reset_code: ShortUUID.expand(params[:reset_code]))
    unless @user
      redirect_to '/reset-password'
      return
    end

    render :reset_password_form
  end

  def reset_password_form_put
    @page.section = 'reset-password'
    @page.title = "Reset password on #{@page.site_name}"

    @user = User.find_by(reset_code: ShortUUID.expand(params[:reset_code]))
    unless @user
      redirect_to '/reset-password'
      return
    end

    @user.password = user_params[:password]
    @user.password = @user.password || 'XXX'
    @user.password_confirmation = user_params[:password_confirmation]
    @user.reset_code = nil
    if @user.save
      redirect_to '/password-changed'
    else
      render :reset_password_form
    end

  end

  def password_changed
    @page.section = 'password-changed'
    @page.title = "Password changed on #{@page.site_name}"
    render :password_changed
  end


  def reset_password
    @page.section = 'reset-password'
    @page.title = "Reset password on #{@page.site_name}"
    render :reset_password
  end

  def reset_password_post
    @page.section = 'reset-password'
    @page.title = "Reset password on #{@page.site_name}"

    @user = User.find_by_email(params[:username_email]) || User.find_by_username(params[:username_email])
    if @user
      unless @user.reset_code
        new_reset_code = SecureRandom.uuid
        @user.update!(reset_code: new_reset_code)
        UserNotifierMailer.send_password_reset_email(@user).deliver
      end
      redirect_to '/reset-password-sent'
    else
      @form_username_email = params[:username_email]
      render :reset_password
    end
  end

  def login_post
    @page.section = 'login'

    user = User.find_by_email(params[:username_email]) || User.find_by_username(params[:username_email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:user] = { id: user.id, email: user.email, username: user.username, active: user.active }
      redirect_to '/'
    else
      @form_username_email = params[:username_email]
      render :login
    end
  end


  def reset_password_sent
    @page.section = 'reset-password-sent'
    @page.title = "Reset password on #{@page.site_name}"
    render :reset_password_sent
  end

  def change_password
    @page.section = 'change-password'
    @page.title = "Change Password on #{@page.site_name}"
    not_found unless logged_in?

    @user = User.find_by(id: current_user_id)

    render :change_password
  end

  def change_password_put
    @page.section = 'change-password'
    @page.title = "Change Password on #{@page.site_name}"
    not_found unless logged_in?

    @user = User.find_by(id: current_user_id)
    if @user && @user.authenticate(user_params_change[:current_password])
      @user.password = user_params_change[:password]
      @user.password = 'XXX' if user_params_change[:password].nil? || user_params_change[:password].blank?
      @user.password_confirmation = user_params_change[:password_confirmation]
      if @user.save
        redirect_to '/password-changed'
        return
      end
    else
      @invalid_password = true
    end

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

  def user_params_change
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

end
