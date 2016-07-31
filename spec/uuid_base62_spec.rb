require 'rails_helper'
require 'shortuuid'
require 'securerandom'

RSpec.describe 'uuid to base62 conversion' do
  it 'should convert uuid to base62' do
    uuid = '4b89f677-5ede-40a5-b0db-b9e170f27cff'
    base62 = '2IXTMpSULP19adgtop0L43'
    expect(ShortUUID.shorten(uuid)).to be == base62
  end

  it 'should be of constant length' do
    10000.times {
      uuid = SecureRandom.uuid
      base62 = ShortUUID.shorten(uuid)
      expect(base62.length).to be >= 19
      expect(base62.length).to be <= 22
    }
  end
end