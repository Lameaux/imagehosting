class Image < ApplicationRecord
  include ActionView::Helpers::TextHelper

  self.primary_key = 'id'

  belongs_to :user, primary_key: 'id', foreign_key: 'user_id', optional: true
  belongs_to :album, primary_key: 'id', foreign_key: 'album_id', optional: true

  ORIGINAL_DIR = 'i'
  THUMBNAIL_DIR = 't'

  THUMBNAIL_WIDTH = 300
  THUMBNAIL_HEIGHT = 300

  ORIGINAL_BASE_URL = Rails.env.production? ? 'http://pngif.com' : 'http://0.0.0.0:3000'
  THUMBNAIL_BASE_URL = Rails.env.production? ? 'http://pngif.com' : 'http://0.0.0.0:3000'

  def as_hash
    {
      id: id,
      short_id: short_id,
      title: title,
      title_plain: title_plain,
      description: description,
      description_plain: description_plain,
      tags: tags,
      tags_array: tags_array,
      file_ext: file_ext,
      file_size: file_size,
      width: width,
      height: height,
      user_id: user_id,
      album_id: album_id,
      short_album_id: short_album_id,
      album_index: album_index,
      hidden: hidden,
      views: views,
      likes: likes,
      created_at: created_at,
      updated_at: updated_at,
    }
  end

  def title_plain
    ActionView::Base.full_sanitizer.sanitize(title)
  end

  def description_plain
    ActionView::Base.full_sanitizer.sanitize(description)
  end

  def tags_array
    Array((tags || '').split(',').map {|x| x.strip.downcase}.delete_if {|x| x.blank?}).uniq
  end

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
    if album && album.title
      "/a/#{short_album_id}/#{album.title.to_ascii.parameterize}"
    else
      "/a/#{short_album_id}"
    end
  end

  def link_to_image
    if title
      "/#{short_id}/#{title.to_ascii.parameterize}"
    else
      "/#{short_id}"
    end

  end

  def link_to_detail(type=nil)
    if album.nil? || type == :images
      link_to_image
    else
      link_to_album
    end
  end

  def title_to_detail(type=nil)
    if album.nil? || type == :images
      title
    else
      album.show_title
    end
  end

end