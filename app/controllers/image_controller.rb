class ImageController < ApplicationController

  def show
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @image = Image.includes(:user).find_by(id: uuid)
    not_found unless @image

    @page.image = "#{BASE_URL}#{@image.web_thumb_path}"
    @page.image_width = Image::THUMBNAIL_WIDTH
    @page.image_height = Image::THUMBNAIL_HEIGHT

    @page.title = "#{@image.title} on #{@page.site_name}"
    render :show
  end

  def edit
    find_by_id_and_user_id
    @image.title = params[:title] if params[:title]
    @image.description = params[:description] if params[:description]
    @image.tags = params[:tags] if params[:tags]
    @image.save!
    render json: @image
  end

  def delete
    find_by_id_and_user_id
    @image.destroy!

    File.delete(@image.local_file_path)
    File.delete(@image.local_thumb_path)
    render plain: 'OK'
  end

  private def find_by_id_and_user_id
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @image = Image.find_by(id: uuid, user_id: session[:user_id])
    not_found unless @image
  end

end
