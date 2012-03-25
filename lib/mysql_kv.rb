module MysqlKv
  TEMP_CACHE_TIME = 1.day
  
  def self.write(key, value, opts = {})
    expires_at = opts[:expires_in]
    expires_at = Time.now + expires_at if expires_at
    key_index = KeyIndex::find_by_key(key) || KeyIndex.new(:key => key)
    key_index.value = value
    key_index.save!

    opts[:expires_in] ||= TEMP_CACHE_TIME
    Rails.cache.write(key, value, opts)
  end
  
  def self.read(key)
    Rails.cache.fetch(key, :expires_in => TEMP_CACHE_TIME) {
      KeyIndex::find_by_key(key).try(:value)
    }
  end
  
  def self.fetch(key, opts = {})
    value = MysqlKv::read(key)
    unless value
      value = yield if block_given?
      MysqlKv::write(key, value, opts) if value
    end
    value
  end
  
  def self.expire
    # Could do a destroy_all, but would rather destroy in batches. This is friendlier
    # to the database.
    KeyIndex::find_each(:conditions => ['expires_at <= ?', Time.now], :batch_size => 1024) { |key_index|
      key_index.destroy
    }
  end
  
  def self.delete(key)
    KeyIndex::find_by_key(key).try(:destroy)
  end
  
  def self.delete_starts_with(starts_with)
    KeyIndex::find_each(:conditions => ['`key` LIKE ?', "#{starts_with}%"], :batch_size => 1024) { |key_index|
      key_index.destroy
    }
  end
end
