namespace :images do
  desc "Fixes memes"
  task fixmemes: :environment do

    user = User.find_by(username: 'lameaux') # 'memes'
    images = Image.where(user_id: user.id).where('created_at < ?', Date.new(2016,9,24)).order(id: :asc)
    images.each do |image|
      crop_image(image, 25)
      create_thumbnail(image)
      puts image.local_file_path
      break
    end

  end

  def crop_image(image, crop_size)

    if image.file_ext == 'gif'
      f = File.open(image.local_file_path)
      blob = f.read
      img = Magick::ImageList.new.from_blob(blob)
      img = img.coalesce
      img.each do |x|
        x.crop!(0, 0, image.width, image.height - crop_size)
      end
      img = img.optimize_layers( Magick::OptimizeLayer )
    else
      img = Magick::Image.read(image.local_file_path).first
      img.crop!(0, 0, image.width, image.height - crop_size)
    end

    img.write(image.local_file_path)

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
