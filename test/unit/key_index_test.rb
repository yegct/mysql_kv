require 'test_helper'

class KeyIndexTest < ActiveSupport::TestCase
  test "can initially set key" do
    assert_nothing_raised do
      k = KeyIndex.new
      k.key = 'key'
    end
  end
  
  test "can not change key once it is set" do
    assert_raise RuntimeError do
      k = KeyIndex.new(:key => 'key')
      k.key = 'new_key'
    end
  end
  
  test "set_key_hash initially sets the key hash" do
    k = KeyIndex.new(:key => 'key')
    k.set_key_hash
    assert_equal(Digest::MD5.digest('key'), k.key_hash)
  end
  
  test "set_key_hash does not recalculate the key hash after it is initially set" do
    k = KeyIndex.new(:key => 'key', :key_hash => 'fake')
    k.set_key_hash
    assert_not_equal(Digest::MD5.digest('key'), k.key_hash)
  end
end
