class User < ApplicationRecord
  self.primary_key = 'id'

  validates :username,
            presence: {message: 'is required'},
            uniqueness: {case_sensitive: false, message: 'is already taken.'},
            length: { minimum: 4, maximum: 255, too_short: 'must be at least 4 characters', too_long: 'must not be longer than 255' }

  validates :email,
            presence: {message: 'is required'},
            uniqueness: {case_sensitive: false, message: 'is already used'},
            format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: 'is invalid'}

  validates :password,
            length: { minimum: 6, maximum: 255, too_short: 'must be at least 6 characters', too_long: 'must not be longer than 255' },
            if: lambda { |m| !m.password.nil? && !m.password.blank? }

  has_secure_password

  def short_activation_code
    ShortUUID.shorten(activation_code)
  end

  def short_reset_code
    ShortUUID.shorten(reset_code)
  end

end