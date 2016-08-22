class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_default_page

  BASE_URL = 'http://0.0.0.0:3000'

  def set_default_page
    @page = Page.new
    @page.image = 'http://0.0.0.0:3000/image.png'
    @page.url = request.original_fullpath
    @page.site_name = 'SITENAME'
    @page.title = 'Image Hosting'
    @page.keywords = 'image, hosting, free, share, jpg, png, gif'
    @page.description = 'Upload JPG, GIF and PNG images. Drag and Drop, browse or upload images from the web.'
    @page.section = ''
    @page.category = nil
    @page.author = 'image-hosting'
    @page.twitter = 'rsstw_it'
    @page.base_url = BASE_URL
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    raise ActionController::BadRequest.new('Bad Request')
  end

end
