class Album < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :user, primary_key: 'id', foreign_key: 'user_id', optional: true

  def short_id
    ShortUUID.shorten(id)
  end

  def title_plain
    ActionView::Base.full_sanitizer.sanitize(title)
  end

  def description_plain
    ActionView::Base.full_sanitizer.sanitize(description)
  end

  def show_title
    title.blank? ? 'Untitled' : title
  end

  def as_hash
    {
      id: id,
      short_id: short_id,
      title: title,
      title_plain: title_plain,
      description: description,
      description_plain: description_plain,
      user_id: user_id,
      hidden: hidden,
      views: views,
      likes: likes,
      created_at: created_at,
      updated_at: updated_at,
    }
  end

end