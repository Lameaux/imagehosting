class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  BASE_URL = 'http://0.0.0.0:3000/'
  THUMB_SUFFIX = '.thumb.jpg'
  THUMB_PREFIX = 'uploads/'

  def local_upload_path(id)
    Rails.root.join('public', 'uploads', id)
  end

  def thumb_url(id)
    "#{BASE_URL}#{THUMB_PREFIX}#{id}#{THUMB_SUFFIX}"
  end

  def img_url(id, file_ext)
    "#{BASE_URL}#{THUMB_PREFIX}#{id}#{file_ext}"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    raise ActionController::BadRequest.new('Bad Request')
  end

end
