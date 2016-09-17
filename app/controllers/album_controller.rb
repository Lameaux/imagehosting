class AlbumController < ApplicationController

  ALBUM_LIMIT = 10
  IMAGES_PER_PAGE = 12

  def show
    @id = params[:id]
    @uuid = ShortUUID.expand(@id)

    @images = Image.where(album_id: @uuid).includes(:user)
                .order(:album_index)
                .offset(params[:offset].to_i.abs)
                .limit(IMAGES_PER_PAGE)

    @album = Album.find_by(id: @uuid)
    not_found if @images.empty? && @album.nil?

    @show_more = @images.length == IMAGES_PER_PAGE
    if @images.length == 0 && params[:offset]
      redirect_to request.path
      return
    end

    first_image = @images.first

    @album = Album.new ({ id: first_image.album_id,
                                    user_id: first_image.user_id,
                                    created_at: first_image.created_at,
                                 }) unless @album

    @next_post_id = next_album

    if (first_image)
      @page.image = "#{first_image.web_thumb_url}"
      @page.keywords = first_image.tags if first_image.tags
    end

    @page.image_width = Image::THUMBNAIL_WIDTH
    @page.image_height = Image::THUMBNAIL_HEIGHT

    @page.title = "#{@album.show_title} on #{@page.site_name}"
    @page.description = @album.description if @album.description


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

  private

  def next_album
    a = Album.where('created_at < ?', @album.created_at).limit(1).first || Album.order(created_at: :desc).limit(1).first
    a.short_id
  end

  def find_by_id_and_user_id

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
