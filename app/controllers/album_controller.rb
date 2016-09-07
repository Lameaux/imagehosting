class AlbumController < ApplicationController

  def show
    @id = params[:id]
    @uuid = ShortUUID.expand(@id)

    @images = Image.where(album_id: @uuid).includes(:user).order(:album_index)
    not_found if @images.empty?

    first_image = @images.first

    @album = Album.find_by(id: first_image.album_id)

    @album = Album.new ({ id: first_image.album_id,
                                    user_id: first_image.user_id,
                                    created_at: first_image.created_at,
                                   title: 'Untitled album',
                                 }) unless @album

    @page.image = "#{first_image.web_thumb_url}"
    @page.image_width = Image::THUMBNAIL_WIDTH
    @page.image_height = Image::THUMBNAIL_HEIGHT

    @page.title = "#{@album.title} on #{@page.site_name}"
    @page.description = @album.description if @album.description
    @page.keywords = first_image.tags if first_image.tags

    render :show
  end

  def edit
    find_by_id_and_user_id
    @album.title = params[:title].strip if params[:title]
    @album.description = params[:description].strip if params[:description]
    @album.save!
    render json: @album.as_hash
  end

  def delete
    find_by_id_and_user_id
    @album.destroy!
    render plain: 'OK'
  end

  private def find_by_id_and_user_id

    @id = params[:id]
    uuid = ShortUUID.expand(@id)

    @album = Album.find_by(id: uuid, user_id: session[:user_id])
    return if @album

    image = Image.find_by(album_id: uuid, user_id: session[:user_id])
    not_found unless image

    @album = Album.new ({
      id: uuid,
      user_id: session[:user_id],
      title: 'Untitled album',
    })

  end

end
