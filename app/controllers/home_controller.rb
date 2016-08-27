class HomeController < ApplicationController

  def index
    @page.section = 'upload'
    @page.title = "Upload image to #{@page.site_name}"

    @album_id = ShortUUID.shorten(SecureRandom.uuid)
    render :index
  end

  def browse
    @page.section = 'browse'
    @page.title = "Browse images on #{@page.site_name}"

    @images = Image.where(hidden: 0).order(created_at: :desc).limit(12)

    render :browse
  end

end
