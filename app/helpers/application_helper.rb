module ApplicationHelper

  def nl2br(s)
    CGI::escapeHTML(s||'').gsub(/\n/, '<br>').html_safe
  end

  def get_album_id
    return @album_id if @album_id
    return @album.short_id if @album
    return @image.short_album_id if @image
  end

  def get_album_next_index
    return 0 unless @album
    return 1 unless @album.persisted?
    return @album.images.maximum(:album_index) + 1
  end

end
