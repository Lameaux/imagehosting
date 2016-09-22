class ImageController < ApplicationController

  def show
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @image = Image.includes(:user).includes(:album).find_by(id: uuid)
    not_found unless @image

    if @image.title && params[:slug].nil?
      redirect_to @image.link_to_image, status: :moved_permanently
      return
    end

    if @image.album.nil?
      @next_post_id = next_image_by_id
    else
      @next_post_id = next_image_in_album
    end

    @page.image = "#{@image.web_thumb_url}"
    @page.image_width = Image::THUMBNAIL_WIDTH
    @page.image_height = Image::THUMBNAIL_HEIGHT

    @page.title = "#{@image.title} on #{@page.site_name}"
    @page.description = @image.description if @image.description
    @page.keywords = @image.tags if @image.tags

    render :show
  end

  def edit
    find_by_id_and_user_id
    @image.title = params[:title].strip if params[:title]
    @image.description = params[:description].strip if params[:description]
    @image.hidden = params[:hidden].to_i if params[:hidden]
    @image.save!
    render json: @image.as_hash
  end

  def delete
    find_by_id_and_user_id
    album_id = @image.album_id
    @image.destroy!

    album = Album.find_by(id: album_id)
    unless album.nil? || album.images.count > 0
      album.destroy!
    end

    File.delete(@image.local_file_path) if File.exist?(@image.local_file_path)
    File.delete(@image.local_thumb_path) if File.exist?(@image.local_thumb_path)
    render plain: 'OK'
  end

  def add_tag
    bad_request if params[:tag].blank?
    find_by_id_and_user_id
    tag = filter_tag(params[:tag])
    bad_request if tag.blank?
    @image.tags = (Array(@image.tags_array) << tag).uniq.join(',')
    @image.save!
    render plain: tag
  end

  def delete_tag
    bad_request if params[:tag].blank?
    find_by_id_and_user_id
    tag = filter_tag(params[:tag])
    bad_request if tag.blank?
    tags = Array(@image.tags_array)
    tags.delete(tag)
    @image.tags = tags.join(',')
    @image.save!
    render plain: 'OK'
  end

  private

  def next_image_in_album
    Image.where(album_id: @image.album.id)
      .where('album_index in (?, 0)', @image.album_index + 1)
      .order(album_index: :desc).limit(1).first_or_initialize(id: @image.id).link_to_image
  end

  def next_image_by_id
    i = Image.includes(:album).where(albums: { id: nil }).where(hidden: 0).where('images.created_at < ?', @image.created_at).limit(1).first ||
      Image.includes(:album).where(albums: { id: nil }).where(hidden: 0).order(created_at: :desc).limit(1).first
    i.link_to_image
  end

  def find_by_id_and_user_id
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @image = Image.find_by(id: uuid, user_id: session[:user_id])
    not_found unless @image
  end

  def filter_tag(tag)
    (tag || '').gsub(/[^\p{Alnum}\p{Space}_-]/, '').downcase
  end

end
