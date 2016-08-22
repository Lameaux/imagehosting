class Image < ApplicationRecord
  self.primary_key = 'id'

  THUMB_SUFFIX = 'thumb'
  UPLOADS_DIR = 'uploads'

  def short_id
    ShortUUID.shorten(id)
  end

  def file_name
    "#{short_id}.#{file_ext}"
  end

  def thumb_file_name
    "#{short_id}.#{THUMB_SUFFIX}.#{file_ext}"
  end

  def local_upload_path
    Rails.root.join('public', UPLOADS_DIR)
  end

  def local_file_path
    "#{local_upload_path}/#{file_name}"
  end

  def local_thumb_path
    "#{local_upload_path}/#{thumb_file_name}"
  end

  def web_upload_path
    "/#{UPLOADS_DIR}"
  end

  def web_file_path
    "#{web_upload_path}/#{file_name}"
  end

  def web_thumb_path
    "#{web_upload_path}/#{thumb_file_name}"
  end

end