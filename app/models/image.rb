class Image < ApplicationRecord
  self.primary_key = 'id'

  ORIGINAL_DIR = 'original'
  THUMBNAIL_DIR = 'thumbnail'

  THUMBNAIL_WIDTH = 350
  THUMBNAIL_HEIGHT = 200

  def short_id
    ShortUUID.shorten(id)
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

end