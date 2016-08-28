require 'securerandom'
require 'shortuuid'
require 'rmagick'
require 'open-uri'
require 'rack/mime'

class UploadController < ApplicationController

  FILE_SIZE_LIMIT = 10 * 1024 * 1024


  MIME_TYPES = {
    'image/gif' => 'gif',
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
  }

  def create

    uuid = SecureRandom.uuid
    @id = ShortUUID.shorten(uuid)
    @image = Image.new(id: uuid)
    @image.user_id = session[:user_id]

    if params[:file_url]
      download_url(params[:file_url])
    elsif params[:file]
      process_upload(params[:file])
    else
      bad_request
    end

    bad_request if File.size(@image.local_file_path) > FILE_SIZE_LIMIT
    @image.file_size = File.size(@image.local_file_path)
    @image.title = params[:file_name] if params[:file_name]
    @image.tags = params[:tags] if params[:tags]
    @image.album_id = ShortUUID.expand(params[:album_id]) if params[:album_id]
    @image.hidden = 1 if params[:hidden]
    set_image_dimensions!(@image)
    @image.save!

    create_thumbnail(@image) unless params[:hidden]

    image_hash = @image.as_json
    image_hash[:id] = @image.short_id
    image_hash[:url] = "#{BASE_URL}/#{@image.short_id}"
    image_hash[:thumb_url] = "#{BASE_URL}#{@image.web_thumb_path}"

    session[:my_images] = session[:my_images] || []
    session[:my_images] << @image.id

    render json: image_hash.to_json
  end

  private

  def supported_content_type(content_type)
    MIME_TYPES.keys.include? content_type
  end

  def download_url(url)
    io = open(url)
    bad_request unless supported_content_type io.content_type

    @image.file_ext = MIME_TYPES[io.content_type]
    @image.title = url
    IO.copy_stream(io, @image.local_file_path, FILE_SIZE_LIMIT)
  end

  def process_upload(io)
    bad_request unless io.is_a? ActionDispatch::Http::UploadedFile
    bad_request unless supported_content_type io.content_type

    @image.file_ext = MIME_TYPES[io.content_type]
    @image.title = io.original_filename
    IO.copy_stream(io.tempfile, @image.local_file_path, FILE_SIZE_LIMIT)
  end

  def set_image_dimensions!(image)
    img = Magick::Image.ping(image.local_file_path).first
    image.width = img.columns
    image.height = img.rows
  end

  def create_thumbnail(image)
    img = Magick::Image.read(image.local_file_path).first

    target = Magick::Image.new(Image::THUMBNAIL_WIDTH, Image::THUMBNAIL_HEIGHT) do
      self.background_color = 'transparent'
      self.format = image.file_ext
    end

    img.resize_to_fit!(Image::THUMBNAIL_WIDTH, Image::THUMBNAIL_HEIGHT)
    target.composite(img, Magick::CenterGravity, Magick::CopyCompositeOp).write(image.local_thumb_path)
  end

end
