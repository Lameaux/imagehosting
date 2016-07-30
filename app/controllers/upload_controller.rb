require 'securerandom'
require 'shortuuid'
class UploadController < ApplicationController

  def create

    uploaded_io = params[:file]

    id = ShortUUID.shorten(SecureRandom.uuid)
    url = "http://0.0.0.0:3000/uploads/#{id}"
    content_type = uploaded_io.content_type
    file_name = uploaded_io.original_filename

    local_file_name = Rails.root.join('public', 'uploads', id)
    File.open(local_file_name, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    file_size = File.size(local_file_name)

    file_info = {
      id: id,
      url: url,
      content_type: content_type,
      file_name: file_name,
      file_size: file_size,
    }
    render json: file_info
  end
end
