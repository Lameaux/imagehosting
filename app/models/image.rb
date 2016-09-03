class Image < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :user, primary_key: 'id', foreign_key: 'user_id', optional: true
  belongs_to :album, primary_key: 'id', foreign_key: 'album_id', optional: true

  ORIGINAL_DIR = 'i'
  THUMBNAIL_DIR = 't'

  THUMBNAIL_WIDTH = 350
  THUMBNAIL_HEIGHT = 200

  ORIGINAL_BASE_URL = 'http://0.0.0.0:3000'
  THUMBNAIL_BASE_URL = 'http://0.0.0.0:3000'

  def short_id
    ShortUUID.shorten(id)
  end

  def short_album_id
    ShortUUID.shorten(album_id)
  end

  def file_name
    "#{short_id}.#{file_ext}"
  end

  def dir_prefix
    "#{short_id[0]}/#{short_id[1]}"
  end

  def local_original_path
    Rails.root.join('public', ORIGINAL_DIR)
  end

  def local_thumbnail_path
    Rails.root.join('public', THUMBNAIL_DIR)
  end

  def local_file_path
    "#{local_original_path}/#{dir_prefix}/#{file_name}"
  end

  def local_thumb_path
    "#{local_thumbnail_path}/#{dir_prefix}/#{file_name}"
  end

  def web_original_path
    "/#{ORIGINAL_DIR}"
  end

  def web_thumbnail_path
    "/#{THUMBNAIL_DIR}"
  end

  def web_file_path
    "#{web_original_path}/#{dir_prefix}/#{file_name}"
  end

  def web_thumb_path
    "#{web_thumbnail_path}/#{dir_prefix}/#{file_name}"
  end

  def web_file_url
    "#{ORIGINAL_BASE_URL}#{web_file_path}"
  end

  def web_thumb_url
    "#{THUMBNAIL_BASE_URL}#{web_thumb_path}"
  end

  def link_to_album
    "/a/#{short_album_id}"
  end

  def link_to_detail(type=nil)
    if album.nil? || type == :images
      "/#{short_id}"
    else
      link_to_album
    end
  end

end