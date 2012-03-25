module MysqlKv
  def self.set(key, value, opts = {})
    expires_at = opts[:expires_at]
    type = if value.is_a?(NilClass)
      :nil
    elsif value.is_a?(FalseClass)
      :false
    elsif value.is_a?(TrueClass)
      :true
    elsif value.is_a?(Fixnum) || value.is_a?(Bignum)
      :integer
    else
      value = value.to_s
      if value.length <= 255
        :string
      else
        :long_string
      end
    end
    KeyIndex.transaction do
      key_index = KeyIndex.find_by_key(key) || KeyIndex.new(:key => key)
      key_index.type = type
      if [:nil, :true, :false].include?(type)
        key_index.key_value_integer.try(:destroy)
        key_index.key_value_string.try(:destroy)
      elsif type == :integer
        key_index.key_value_integer ||= KeyValueInteger.new
        key_index.key_value_integer.value = value
        key_index.key_value_string.try(:destroy)
      elsif type == :string
        key_index.key_value_string ||= KeyValueString.new
        key_index.key_value_string.value = value
        key_index.key_value_integer.try(:destroy)
      elsif type == :long_string
        key_index.key_value_long_string ||= KeyValueLongString.new
        key_index.key_value_long_string.value = value
        key_index.key_value_integer.try(:destroy)
        key_index.key_value_string.try(:destroy)
      end
      key_index.expires_at = expires_at
      key_index.save!
      key_index.key_value_integer.try(:save!)
      key_index.key_value_string.try(:save!)
      key_index.key_value_long_string.try(:save!)
    end
  end
  
  def self.get(key)
    key_index = KeyIndex.find_by_key(key)
    if key_index.nil?
      raise 'Not Found'
    elsif key_index.type == :nil
      return nil
    elsif key_index.type == :true
      return true
    elsif key_index.type == :false
      return false
    elsif key_index.type == :integer
      return key_index.key_value_integer.value
    elsif key_index.type == :string
      return key_index.key_value_string.value
    elsif key_index.type == :long_string
      return key_index.key_value_long_string.value
    end
  end
  
  def self.expire
    # Could do a destroy_all, but would rather destroy in batches. This is friendlier
    # to the database.
    KeyIndex.find_each(:conditions => ['expires_at <= ?', Time.now], :batch_size => 1024) { |key_index|
      key_index.destroy
    }
  end
end