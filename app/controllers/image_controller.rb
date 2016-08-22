require 'shortuuid'
require 'rack/mime'

class ImageController < ApplicationController

  def show
    find_by_id

    @page.title = "#{@image.title} on #{@page.site_name}"
    render :show
  end

  def edit
    find_by_id
    @image.update(title: params[:title])
    render plain: 'OK'
  end

  def delete
    find_by_id
    @image.destroy!

    File.delete("#{local_upload_path(@id)}#{@image.file_ext}")
    File.delete("#{local_upload_path(@id)}#{THUMB_SUFFIX}")
    render plain: 'OK'
  end


  private def find_by_id
    @id = params[:id]
    uuid = ShortUUID.expand(@id)
    @image = Image.find_by(id: uuid)
    not_found unless @image
  end

end
