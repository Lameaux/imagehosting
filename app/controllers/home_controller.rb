class HomeController < ApplicationController

  def index
    @page.section = 'upload'
    @page.title = "Upload image to #{@page.site_name}"

    @collection_id = ShortUUID.shorten(SecureRandom.uuid)
    render :index
  end

  def browse
    @page.section = 'browse'
    @page.title = "Browse images on #{@page.site_name}"

    @images = Image.order(created_at: :desc).limit(12)

    render :browse
  end

end
