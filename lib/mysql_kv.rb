module MysqlKv
  TEMP_CACHE_TIME = 1.day
  
  def self.write(key, value, opts = {})
    expires_at = opts[:expires_in]
    expires_at = Time.zone.now + expires_at if expires_at
    key_index = KeyIndex::find_by_key(key) || KeyIndex.new(:key => key)
    key_index.value = value
    key_index.expires_at = expires_at
    key_index.save!

    opts[:expires_in] ||= TEMP_CACHE_TIME
    Rails.cache.write(KeyIndex::CACHE_PREFIX + key, value, opts)
  end
  
  def self.read(key)
    Rails.cache.fetch(KeyIndex::CACHE_PREFIX + key, :expires_in => TEMP_CACHE_TIME) {
      key_index = KeyIndex::find_by_key(key)
      key_index.try(:value)
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
    KeyIndex::find_each(:conditions => ['expires_at <= ?', Time.zone.now], :batch_size => 1024) { |key_index|
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
  
  # Increment a value by the specified amount. If the key does not
  # already exist, or if the key is not an integer, it will be set
  # to value.
  # For example:
  # MysqlKv::incr('my_incr', 1) # => 1
  # MysqlKv::incr('my_incr', 1) # => 2
  # MysqlKv::write('my_incr', 'string') # => string
  # MysqlKv::incr('my_incr', 1) # => 1
  # Note that by necessity, we skip the Rails cache.
  def self.incr(key, increment, opts = {})
    key_index = KeyIndex::find_by_key(key)
    if key_index.nil? || key_index.type != :integer
      value = MysqlKv::write(key, increment, opts)
    else
      KeyValueInteger::update_counters(key_index.id, :value => increment)
      Rails.cache.delete(KeyIndex::CACHE_PREFIX + key)
    end
    # Have to do this as a separate step because Rails doesn't provide a
    # way to do an update-and-read-updated-value in a single step.
    MysqlKv::read(key)
  end
end
