module ApplicationHelper

  def nl2br(s)
    CGI::escapeHTML(s||'').gsub(/\n/, '<br>').html_safe
  end

end
