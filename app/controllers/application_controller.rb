class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    raise ActionController::BadRequest.new('Bad Request')
  end

end
