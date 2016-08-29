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

  def search
    @page.section = 'search'
    @page.title = "Search images on #{@page.site_name}"

    @images = Image.where(hidden: 0).order(created_at: :desc).limit(12)

    render :search
  end

  def my
    @page.section = 'my'
    @page.title = "My images on #{@page.site_name}"

    @images = Image.where(user_id: session[:user_id]).order(created_at: :desc)

    render :my
  end

  def terms
    render :terms
  end

end
