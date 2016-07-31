require 'shortuuid'
require 'rack/mime'

class ImageController < ApplicationController

  def show
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    image = Image.find_by(id: uuid)
    not_found unless image

    @title = image.title
    @thumb_url = thumb_url(@id)
    @img_url = img_url(@id, image.file_ext)

    render :show
  end

  def edit
    @id = params[:id]
    not_found unless File.file? local_upload_path(@id)
    render plain: 'OK'
  end

  def delete
    @id = params[:id]
    not_found unless File.file? local_upload_path(@id)

    File.delete(local_upload_path(@id))
    File.delete("#{local_upload_path(@id)}#{THUMB_SUFFIX}")

    render plain: 'OK'
  end

end
