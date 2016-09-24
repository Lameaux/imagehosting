class HomeController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  IMAGES_PER_PAGE = 12

  def upload
    @page.section = 'upload'
    @page.title = "Upload image to #{@page.site_name}"

    @album_id = ShortUUID.shorten(SecureRandom.uuid)

    render :upload
  end

  def browse
    @page.section = 'browse'
    params[:sort] = params[:sort] || 'popular'

    @page.title = "#{params[:sort].capitalize} images on #{@page.site_name}"

    params[:type] = params[:type] || 'any'
    params[:size] = params[:size] || 'any'

    query = Image.includes(:album)

    if params[:sort] == 'new'
      query.order!(created_at: :desc)
    else
      query.order!(views: :desc)
    end

    unless params[:type] == 'any'
      query.where!(file_ext: params[:type])
    end

    case params[:size]
      when 'icon'
        query.where!('width <= 256')
      when 'medium'
        query.where!('width between 256 and 800')
      when 'large'
        query.where!('width > 800')
      else
        nil
    end

    @images = query.group(:album_id).offset(params[:offset].to_i.abs).limit(IMAGES_PER_PAGE)

    @show_more = @images.length == IMAGES_PER_PAGE
    if @images.length == 0 && params[:offset]
      redirect_to request.path
      return
    end

    @images = @images.to_a.delete_if { |image| image.hidden == 1 }

    if params[:ajax]
      body = render_to_string 'shared/_browse_ajax', layout: false
      render json: {body: body, offset: params[:offset].to_i + @images.length, show_more: @show_more}
    else
      render :browse
    end

  end

  def my_images
    @page.section = 'my'
    @page.title = "My images on #{@page.site_name}"
    @images = Image.includes(:user).where(user_id: session[:user_id])
                .order(created_at: :desc, album_index: :desc)
                .offset(params[:offset].to_i.abs).limit(IMAGES_PER_PAGE)

    @show_more = @images.length == IMAGES_PER_PAGE
    if @images.length == 0 && params[:offset]
      redirect_to request.path
      return
    end

    @type = :images

    if params[:ajax]
      body = render_to_string 'shared/_browse_ajax', layout: false
      render json: {body: body, offset: params[:offset].to_i + @images.length, show_more: @show_more}
    else
      render :my
    end

  end

  def my_albums
    @page.section = 'my'
    @page.title = "My albums on #{@page.site_name}"

    @images = Image.includes(:user).includes(:album)
                .where(user_id: session[:user_id], albums: { user_id: session[:user_id] })
                .order(created_at: :desc)
                .group(:album_id)
                .offset(params[:offset].to_i.abs).limit(IMAGES_PER_PAGE)

    @show_more = @images.length == IMAGES_PER_PAGE
    if @images.length == 0 && params[:offset]
      redirect_to request.path
      return
    end

    @type = :albums

    if params[:ajax]
      body = render_to_string 'shared/_browse_ajax', layout: false
      render json: {body: body, offset: params[:offset].to_i + @images.length, show_more: @show_more}
    else
      render :my
    end

  end


  def user_images

    user = User.find_by(username: params[:username]) or not_found

    if user.id == current_user_id
      redirect_to '/my/images'
      return
    end

    @page.section = 'user'
    @page.title = "#{user.username} images on #{@page.site_name}"

    @images = Image.includes(:user).where(user_id: user.id)
                .order(created_at: :desc, album_index: :desc)
                .offset(params[:offset].to_i.abs).limit(IMAGES_PER_PAGE)

    @show_more = @images.length == IMAGES_PER_PAGE
    if @images.length == 0 && params[:offset]
      redirect_to request.path
      return
    end

    @type = :images

    if params[:ajax]
      body = render_to_string 'shared/_browse_ajax', layout: false
      render json: {body: body, offset: params[:offset].to_i + @images.length, show_more: @show_more}
    else
      render :user_gallery
    end

  end

  def user_albums

    user = User.find_by(username: params[:username]) or not_found

    if user.id == current_user_id
      redirect_to '/my/albums'
      return
    end

    @page.section = 'user'
    @page.title = "#{user.username} albums on #{@page.site_name}"

    @images = Image.includes(:user).includes(:album)
                .where(user_id: user.id, albums: { user_id: user.id })
                .order(created_at: :desc)
                .group(:album_id)
                .offset(params[:offset].to_i.abs).limit(IMAGES_PER_PAGE)

    @show_more = @images.length == IMAGES_PER_PAGE
    if @images.length == 0 && params[:offset]
      redirect_to request.path
      return
    end

    @type = :albums

    if params[:ajax]
      body = render_to_string 'shared/_browse_ajax', layout: false
      render json: {body: body, offset: params[:offset].to_i + @images.length, show_more: @show_more}
    else
      render :user_gallery
    end

  end

  def terms
    @page.section = 'terms'
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

    @images = Image.where(hidden: 0).order(created_at: :desc).limit(10).all
    @images.each do |image|

      image_title = strip_tags(image.title || '').gsub(/[<>]/, CGI::Util::TABLE_FOR_ESCAPE_HTML__)
      image_description = strip_tags(image.description || '').gsub(/[<>]/, CGI::Util::TABLE_FOR_ESCAPE_HTML__)

      image_description_full = "<a href=\"#{@page.base_url}#{image.link_to_detail(:images)}\" alt=\"#{image_title}\">" <<
        "<img alt=\"#{image_title}\" src=\"#{image.web_thumb_url}\" />" <<
        '</a>' <<
        '<p>' <<
        "<a href=\"#{@page.base_url}#{image.link_to_detail(:images)}\" alt=\"#{image_title}\">" <<
        "#{image_title}" <<
        '</a>' <<
        '</p>'
      image_description_full << "<p>#{image_description}</p>" unless image_description.blank?

      output << "
                  <item>
                      <title><![CDATA[#{image_title}]]></title>
                      <link>#{@page.base_url}#{image.link_to_detail(:images)}</link>
                      <guid>#{@page.base_url}#{image.link_to_detail(:images)}</guid>
                      <description><![CDATA[#{image_description_full}]]></description>"

      image.tags_array.each do |tag|
        output << "     <category>#{tag}</category>"
      end
      output << "     <pubDate>#{image.created_at.utc.strftime('%a, %d %b %Y %H:%M:%S')} GMT</pubDate>
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

    Image.where(hidden: 0).order(created_at: :desc).limit(40000).each do |image|
      output << "<url>
                    <loc>#{@page.base_url}#{image.link_to_detail(:images)}</loc>
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
