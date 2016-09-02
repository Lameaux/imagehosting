class AlbumController < ApplicationController

  def show
    find_by_id

    @images = Image.where(album_id: @uuid).includes(:user).order(:album_index)
    not_found if @images.empty?

    first_image = @images.first

    @album = @album || Album.new({
                                   id: first_image.album_id,
                                   user_id: first_image.user_id,
                                   created_at: first_image.created_at,
                                 })

    @page.image = "#{BASE_URL}#{first_image.web_thumb_path}"
    @page.image_width = Image::THUMBNAIL_WIDTH
    @page.image_height = Image::THUMBNAIL_HEIGHT

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
    @uuid = ShortUUID.expand(@id)
    @album = Album.find_by(id: @uuid)
  end

end
