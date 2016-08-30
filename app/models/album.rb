class Album < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :user, primary_key: 'id', foreign_key: 'user_id', optional: true

  def short_id
    ShortUUID.shorten(id)
  end

end