class ImageController < ApplicationController

  def show
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @image = Image.includes(:user).includes(:album).find_by(id: uuid)
    not_found unless @image

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
    @image.save!
    render json: @image.as_hash
  end

  def delete
    find_by_id_and_user_id
    @image.destroy!

    File.delete(@image.local_file_path)
    File.delete(@image.local_thumb_path)
    render plain: 'OK'
  end

  def add_tag
    bad_request if params[:tag].blank?
    find_by_id_and_user_id
    tag = filter_tag(params[:tag])
    @image.tags = (Array(@image.tags_array) << tag).uniq.join(',')
    @image.save!
    render plain: tag
  end

  def delete_tag
    bad_request if params[:tag].blank?
    find_by_id_and_user_id
    tag = filter_tag(params[:tag])
    tags = Array(@image.tags_array)
    tags.delete(tag)
    @image.tags = tags.join(',')
    @image.save!
    render plain: 'OK'
  end

  private def find_by_id_and_user_id
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @image = Image.find_by(id: uuid, user_id: session[:user_id])
    not_found unless @image
  end

  def filter_tag(tag)
    (tag || '').gsub(/[^\p{Alnum}\p{Space}_-]/, '').downcase
  end

end
