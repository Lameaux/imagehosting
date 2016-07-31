require 'securerandom'
require 'shortuuid'
require 'rmagick'

class UploadController < ApplicationController

  BASE_URL = 'http://0.0.0.0:3000/'
  THUMB_SUFFIX = '.thumb.jpg'

  def create

    uploaded_io = params[:file]

    id = ShortUUID.shorten(SecureRandom.uuid)
    url = "#{BASE_URL}#{id}"
    content_type = uploaded_io.content_type
    file_name = params[:file_name] ? params[:file_name] : uploaded_io.original_filename

    local_file_name = Rails.root.join('public', 'uploads', id)
    File.open(local_file_name, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    file_size = File.size(local_file_name)

    create_thumbnail(local_file_name)
    thumb_url = "#{url}#{THUMB_SUFFIX}"

    file_info = {
      id: id,
      url: url,
      thumb_url: thumb_url,
      content_type: content_type,
      file_name: file_name,
      file_size: file_size,
    }
    render json: file_info
  end

  def create_thumbnail(img_file_name)

    width = 400
    height = 300

    local_file_name_thumb = "#{img_file_name}#{THUMB_SUFFIX}"

    # create thumbnail
    img = Magick::Image.read(img_file_name).first

    target = Magick::Image.new(width, height) do
      self.background_color = 'white'
      self.format = 'JPG'
    end
    img.resize_to_fill!(width, height)
    target.composite(img, Magick::CenterGravity, Magick::CopyCompositeOp).write(local_file_name_thumb)
    local_file_name_thumb
  end

end
