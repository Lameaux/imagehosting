require 'securerandom'
require 'shortuuid'
require 'rmagick'
require 'open-uri'
require 'rack/mime'

class UploadController < ApplicationController

  FILE_SIZE_LIMIT = 500 * 1024

  def create

    uuid = SecureRandom.uuid
    id = ShortUUID.shorten(uuid)
    url = "#{BASE_URL}/#{id}"
    thumb_url = "#{BASE_URL}/#{THUMB_PREFIX}#{id}#{THUMB_SUFFIX}"
    local_file_name = local_upload_path(id)

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


    file_info[:file_size] = File.size(local_file_name)
    bad_request if file_info[:file_size] > FILE_SIZE_LIMIT

    file_info[:file_name] = params[:file_name] if params[:file_name]

    create_thumbnail(local_file_name)

    file_ext = Rack::Mime::MIME_TYPES.invert[file_info[:content_type]]

    File.rename(local_file_name, "#{local_file_name}#{file_ext}")

    image = Image.new({
      id: uuid,
      title: file_info[:file_name],
      file_ext: file_ext,
                      })
    image.save!

    render json: file_info
  end

  private

  def download_url(url, file_info, local_file_name)
    img = open(url)
    file_info[:content_type] = img.content_type
    file_info[:file_name] = url
    bad_request unless img.content_type.start_with?('image')
    IO.copy_stream(img, local_file_name, FILE_SIZE_LIMIT)
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
    height = 400

    local_file_name_thumb = "#{img_file_name}#{THUMB_SUFFIX}"

    # create thumbnail
    img = Magick::Image.read(img_file_name).first

    target = Magick::Image.new(width, height) do
      self.background_color = 'transparent'
      self.format = 'PNG'
    end
    img.resize_to_fit!(width, height)
    target.composite(img, Magick::CenterGravity, Magick::CopyCompositeOp).write(local_file_name_thumb)
    local_file_name_thumb
  end

end
