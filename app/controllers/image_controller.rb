class ImageController < ApplicationController

  def show
    @id = params[:id]
    not_found unless File.file? local_upload_path(@id)
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
