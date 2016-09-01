class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_user, :set_default_page

  BASE_URL = 'http://0.0.0.0:3000'

  def set_user
    session[:user_id] = session[:user_id] || SecureRandom.uuid
  end

  def current_user
    session[:user]
  end
  helper_method :current_user

  def current_user_id
    session[:user_id]
  end
  helper_method :current_user_id


  def logged_in?
    !session[:user].nil?
  end
  helper_method :logged_in?


  def set_default_page
    @page = Page.new
    @page.image = "#{BASE_URL}/img/pngifcom.png"
    @page.image_width = 600
    @page.image_height = 315
    @page.url = request.original_fullpath
    @page.site_name = 'pngif.com'
    @page.site_domain = 'pngif.com'
    @page.title = 'Upload PNG, JPG, GIF images and share'
    @page.keywords = 'image, png, gif, jpeg, share, hosting'
    @page.description = 'Upload PNG, JPG, GIF images. Drag & drop, browse files, paste from clipboard or upload images from the web.'
    @page.section = ''
    @page.category = nil
    @page.author = 'pngif.com'
    @page.twitter = 'pngif_com'
    @page.facebook = 'pngif_com'
    @page.base_url = BASE_URL
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    raise ActionController::BadRequest.new('Bad Request')
  end

end
