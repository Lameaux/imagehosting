require 'rails_helper'
require 'shortuuid'

RSpec.describe 'uuid to base62 conversion' do
  it 'should convert uuid to base62' do
    uuid = '4b89f677-5ede-40a5-b0db-b9e170f27cff'
    base62 = '2IXTMpSULP19adgtop0L43'
    expect(ShortUUID.shorten(uuid)).to be == base62
  end
end