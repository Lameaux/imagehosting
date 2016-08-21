class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_default_page

  BASE_URL = 'http://0.0.0.0:3000'
  THUMB_SUFFIX = '.thumb.png'
  THUMB_PREFIX = 'uploads/'

  def set_default_page
    @page = Page.new
    @page.image = 'http://0.0.0.0:3000/image.png'
    @page.url = request.original_fullpath
    @page.site_name = 'SITENAME'
    @page.title = 'Image Hosting - SITENAME'
    @page.keywords = 'image, hosting, free, share, jpg, png, gif'
    @page.description = 'Upload JPG, GIF and PNG images. Drag and Drop, browse or upload images from the web.'
    @page.section = ''
    @page.category = nil
    @page.author = 'image-hosting'
    @page.twitter = '@twitter'
    @page.base_url = BASE_URL
  end

  def local_upload_path(id)
    Rails.root.join('public', 'uploads', id)
  end

  def thumb_url(id)
    "#{BASE_URL}/#{THUMB_PREFIX}#{id}#{THUMB_SUFFIX}"
  end

  def img_url(id, file_ext)
    "#{BASE_URL}/#{THUMB_PREFIX}#{id}#{file_ext}"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    raise ActionController::BadRequest.new('Bad Request')
  end

end
