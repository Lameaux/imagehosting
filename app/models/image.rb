class Image < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :user, primary_key: 'id', foreign_key: 'user_id', optional: true
  belongs_to :album, primary_key: 'id', foreign_key: 'album_id', optional: true

  ORIGINAL_DIR = 'original'
  THUMBNAIL_DIR = 'thumbnail'

  THUMBNAIL_WIDTH = 350
  THUMBNAIL_HEIGHT = 200

  # separate domain for thumbnails and originals

  def short_id
    ShortUUID.shorten(id)
  end

  def short_album_id
    ShortUUID.shorten(album_id)
  end

  def file_name
    "#{short_id}.#{file_ext}"
  end

  def local_original_path
    Rails.root.join('public', ORIGINAL_DIR)
  end

  def local_thumbnail_path
    Rails.root.join('public', THUMBNAIL_DIR)
  end

  def local_file_path
    "#{local_original_path}/#{file_name}"
  end

  def local_thumb_path
    "#{local_thumbnail_path}/#{file_name}"
  end

  def web_original_path
    "/#{ORIGINAL_DIR}"
  end

  def web_thumbnail_path
    "/#{THUMBNAIL_DIR}"
  end

  def web_file_path
    "#{web_original_path}/#{file_name}"
  end

  def web_thumb_path
    "#{web_thumbnail_path}/#{file_name}"
  end

  def link_to_album
    "/album/#{short_album_id}"
  end

  def link_to_detail
    if album.nil?
      "/#{short_id}"
    else
      link_to_album
    end
  end

end