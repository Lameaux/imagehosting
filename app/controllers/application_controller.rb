class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  THUMB_SUFFIX = '.thumb.jpg'
  THUMB_PREFIX = 'uploads/'

  def local_upload_path(id)
    Rails.root.join('public', 'uploads', id)
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    raise ActionController::BadRequest.new('Bad Request')
  end

end
