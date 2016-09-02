class HomeController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  def upload
    @page.section = 'upload'
    @page.title = "Upload image to #{@page.site_name}"

    @album_id = ShortUUID.shorten(SecureRandom.uuid)
    render :upload
  end

  def browse
    @page.section = 'browse'
    @page.title = "Browse images on #{@page.site_name}"

    params[:sort] = params[:sort] || 'popular'
    params[:type] = params[:type] || 'all'
    params[:size] = params[:size] || 'all'

    @images = Image.where(album_index: 0).order(created_at: :desc).limit(12)

    render :browse
  end

  def search
    @page.section = 'search'
    @page.title = "Search images on #{@page.site_name}"

    render :search
  end

  def my
    @page.section = 'my'
    @page.title = "My images on #{@page.site_name}"

    @images = Image.includes(:user).where(user_id: session[:user_id]).order(created_at: :desc, album_index: :desc)

    render :my
  end

  def terms
    @page.section = 'my'
    @page.title = "Terms of service - #{@page.site_name}"

    render :terms
  end

  def rss

    output = '<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>' << "#{@page.site_name}" << '</title>
    <link>' << @page.base_url << '</link>
    <category>images</category>
    <description>' << sanitize(@page.description) << '</description>
    <lastBuildDate>' << Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S') << ' GMT</lastBuildDate>
    <atom:link href="' << "#{@page.base_url}#{@page.url}" << '" rel="self" type="application/rss+xml" />
    <image>
      <url>' << @page.image << '</url>
      <title>' << @page.title << '</title>
      <link>' << @page.base_url << '</link>
    </image>
    '

    @images = Image.order(created_at: :desc).limit(10).all
    @images.each do |image|

      image_title = strip_tags(image.title || '').gsub(/[<>]/, CGI::Util::TABLE_FOR_ESCAPE_HTML__)
      image_description = strip_tags(image.description || '').gsub(/[<>]/, CGI::Util::TABLE_FOR_ESCAPE_HTML__)

      image_description = "<a href=\"#{@page.base_url}/#{image.short_id}\" alt=\"#{image_title}\">" <<
        "<img alt=\"#{image_title}\" src=\"#{@page.base_url}#{image.web_thumb_path}\" />" <<
        '</a>' <<
        '<p>' <<
        "<a href=\"#{@page.base_url}/#{image.short_id}\" alt=\"#{image_title}\">" <<
        "#{image_title}" <<
        '</a>' <<
        '</p>' <<
        "<p>#{image_description}</p>"

      output << "
                  <item>
                      <title><![CDATA[#{image_title}]]></title>
                      <link>#{@page.base_url}/#{image.short_id}</link>
                      <guid>#{@page.base_url}/#{image.short_id}</guid>
                      <description><![CDATA[#{image_description}]]></description>
                      <category>#{image.tags}</category>
                      <pubDate>#{image.created_at.utc.strftime('%a, %d %b %Y %H:%M:%S')} GMT</pubDate>
                  </item>"
    end

    output << '
  </channel>
</rss>'

    render xml: output

  end

  def sitemap

    output = '<?xml version="1.0" encoding="utf-8"?>'
    output << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

    output << "<url>
                    <loc>#{@page.base_url}</loc>
                    <lastmod>#{Time.now.strftime('%Y-%m-%d')}</lastmod>
                    <changefreq>weekly</changefreq>
                    <priority>1</priority>
                </url>
    "

    Album.order(created_at: :desc).limit(1000).each do |album|
      output << "<url>
                    <loc>#{@page.base_url}/album/#{album.short_id}</loc>
                    <lastmod>#{Time.now.strftime('%Y-%m-%d')}</lastmod>
                    <changefreq>weekly</changefreq>
                    <priority>0.8</priority>
              </url>
    "
    end

    Image.order(created_at: :desc).limit(1000).each do |image|
      output << "<url>
                    <loc>#{@page.base_url}/#{image.short_id}</loc>
                    <lastmod>#{Time.now.strftime('%Y-%m-%d')}</lastmod>
                    <changefreq>weekly</changefreq>
                    <priority>0.8</priority>
              </url>
    "
    end

    output << '</urlset>'

    render xml: output
  end


end
