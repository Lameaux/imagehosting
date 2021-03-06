require 'securerandom'
require 'shortuuid'
require 'rmagick'
require 'open-uri'
require 'rack/mime'

class UploadController < ApplicationController

  skip_before_action :verify_authenticity_token

  FILE_SIZE_LIMIT = 10 * 1024 * 1024


  MIME_TYPES = {
    'image/gif' => 'gif',
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'application/octet-stream' => '',
  }
  MIME_TYPES.default = ''

  def create

    if params[:username]
      user = User.find_by(username: params[:username], active: 1)
      if user && user.authenticate(params[:password])
        params[:token_id] = session[:token_id]
        session[:user_id] = user.id
      end
    end

    bad_request if params[:token_id] != session[:token_id]

    uuid = SecureRandom.uuid
    @id = ShortUUID.shorten(uuid)
    @image = Image.new(id: uuid)
    @image.user_id = session[:user_id]
    @image.album_id = SecureRandom.uuid
    @image.album_index = 0

    if params[:file_url]
      download_url(params[:file_url])
    elsif params[:file]
      process_upload(params[:file])
    else
      bad_request
    end

    bad_request if File.size(@image.local_file_path) > FILE_SIZE_LIMIT
    @image.file_size = File.size(@image.local_file_path)
    @image.title = params[:title].strip if params[:title]
    @image.tags = @image.file_ext
    @image.tags = "#{@image.file_ext},#{params[:tags]}".strip if params[:tags]
    @image.album_id = ShortUUID.expand(params[:album_id]) if params[:album_id]
    @image.album_index = params[:album_index] if params[:album_index]
    @image.hidden = params[:hidden].to_i if params[:hidden]
    set_image_format!(@image)
    set_image_dimensions!(@image)
    @image.save!

    if params[:album_index].to_i > 0
      album = Album.find_or_create_by(id: @image.album_id, user_id: @image.user_id)
      album.title = params[:album_title] if params[:album_title]
      album.hidden = params[:album_hidden].to_i if params[:album_hidden]
      album.save!
    end

    create_thumbnail(@image)

    image_hash = @image.as_json
    image_hash[:id] = @image.short_id
    image_hash[:url] = "#{BASE_URL}/#{@image.short_id}"
    image_hash[:thumb_url] = "#{@image.web_thumb_url}"

    render json: image_hash.to_json
  rescue => e
    if @image
      @image.destroy
      File.delete @image.local_file_path rescue nil
      File.delete @image.local_thumb_path rescue nil
    end
  end

  private

  def set_image_format!(image)
    if (image.file_ext.blank?)
      img = Magick::Image.ping(image.local_file_path).first
      bad_request unless supported_format img.format.downcase
      old_file_name = image.local_file_path
      image.file_ext = img.format.downcase
      File.rename(old_file_name, image.local_file_path)
    end
  end

  def supported_content_type(content_type)
    MIME_TYPES.keys.include? content_type
  end

  def supported_format(format)
    MIME_TYPES.values.include? format
  end

  def download_url(url)
    io = open(url)
    bad_request unless supported_content_type io.content_type

    @image.file_ext = MIME_TYPES[io.content_type]
    @image.title = url
    FileUtils.mkdir_p(File.dirname(@image.local_file_path))
    IO.copy_stream(io, @image.local_file_path, FILE_SIZE_LIMIT)
  end

  def process_upload(io)
    bad_request unless io.is_a? ActionDispatch::Http::UploadedFile
    bad_request unless supported_content_type io.content_type

    @image.file_ext = MIME_TYPES[io.content_type]
    @image.title = io.original_filename
    FileUtils.mkdir_p(File.dirname(@image.local_file_path))
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
      self.background_color = 'Transparent'
      self.format = image.file_ext
    end

    img.resize_to_fit!(Image::THUMBNAIL_WIDTH, Image::THUMBNAIL_HEIGHT)
    FileUtils.mkdir_p(File.dirname(image.local_thumb_path))
    final = target.composite(img, Magick::CenterGravity, Magick::CopyCompositeOp)

    if image.file_ext == 'gif'
      mark = Magick::Image.read(Rails.root.join('public', 'img', 'play.png')).first
      mark.background_color = 'Transparent'
      final = final.watermark(mark, 0.8, 0, Magick::CenterGravity)
    end

    final.write(image.local_thumb_path)

  end

end
