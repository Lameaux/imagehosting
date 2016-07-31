require 'securerandom'
require 'shortuuid'
require 'rmagick'
require 'open-uri'

class UploadController < ApplicationController

  BASE_URL = 'http://0.0.0.0:3000/'
  THUMB_SUFFIX = '.thumb.jpg'

  def create

    bad_request if Random.rand(2) == 0

    id = ShortUUID.shorten(SecureRandom.uuid)
    url = "#{BASE_URL}#{id}"
    thumb_url = "#{url}#{THUMB_SUFFIX}"
    local_file_name = Rails.root.join('public', 'uploads', id)

    file_info = {
      id: id,
      url: url,
      thumb_url: thumb_url,
      content_type: 'image/jpg',
      file_name: '',
      file_size: 0,
    }

    if params[:file_url]
      download_url(params[:file_url], file_info, local_file_name)
    elsif params[:file]
      process_upload(params[:file], file_info, local_file_name)
    else
      bad_request
      return
    end

    create_thumbnail(local_file_name)

    file_info[:file_name] = params[:file_name] if params[:file_name]
    file_info[:file_size] = File.size(local_file_name)

    render json: file_info
  end

  private

  def download_url(url, file_info, local_file_name)
    img = open(url)
    file_info[:content_type] = img.content_type
    bad_request unless img.content_type.start_with?('image')
    IO.copy_stream(img, local_file_name)
  end

  def process_upload(uploaded_io, file_info, local_file_name)
    bad_request unless uploaded_io.is_a? ActionDispatch::Http::UploadedFile
    bad_request unless uploaded_io.content_type.start_with?('image')

    File.open(local_file_name, 'wb') do |file|
      file.write(uploaded_io.read)
    end
    file_info[:content_type] = uploaded_io.content_type
    file_info[:file_name] = uploaded_io.original_filename
  end

  def create_thumbnail(img_file_name)

    width = 500
    height = 500

    local_file_name_thumb = "#{img_file_name}#{THUMB_SUFFIX}"

    # create thumbnail
    img = Magick::Image.read(img_file_name).first

    target = Magick::Image.new(width, height) do
      self.background_color = 'white'
      self.format = 'JPG'
    end
    img.resize_to_fit!(width, height)
    target.composite(img, Magick::CenterGravity, Magick::CopyCompositeOp).write(local_file_name_thumb)
    local_file_name_thumb
  end

end
