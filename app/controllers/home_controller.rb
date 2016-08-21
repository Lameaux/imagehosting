class HomeController < ApplicationController

  def index
    @page.section = 'upload'
    @collection_id = ShortUUID.shorten(SecureRandom.uuid)
    render :index
  end
end
