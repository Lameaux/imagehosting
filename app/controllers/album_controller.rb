class AlbumController < ApplicationController

  def show
    find_by_id
    @album = @album || Album.new

    # @page.image = "#{BASE_URL}#{@image.web_thumb_path}"
    # @page.image_width = Image::THUMBNAIL_WIDTH
    # @page.image_height = Image::THUMBNAIL_HEIGHT

    @page.title = "Album #{@album.title} on #{@page.site_name}"
    render :show
  end

  def edit
    find_by_id
    not_found unless @album
    @album.update(title: params[:title])
    render plain: 'OK'
  end

  def delete
    find_by_id
    not_found unless @album
    @album.destroy!
    render plain: 'OK'
  end

  private def find_by_id
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @album = Album.find_by(id: uuid)
  end

end
