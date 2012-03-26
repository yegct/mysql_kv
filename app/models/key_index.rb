class KeyIndex < ActiveRecord::Base
  CACHE_PREFIX='MysqlKv/'
  ALLOWED_TYPES = {
    :false => 1,
    :true => 2,
    :integer => 3,
    :string => 4,
    :long_string => 5
  }
  ALLOWED_TYPES_INVERT = ALLOWED_TYPES.invert
  
  has_one :key_value_integer,
    :dependent => :destroy
  has_one :key_value_string,
    :dependent => :destroy
  has_one :key_value_long_string,
    :dependent => :destroy
  
  validates_numericality_of :data_type, :greater_than_or_equal_to => 0
  validates_length_of :key, :maximum => 255
  
  before_save :set_key_hash
  after_save :destroy_values_on_type_change
  after_destroy :remove_from_cache
  
  def self.calculate_key_hash(key)
    Digest::MD5.digest(key)
  end
  
  def self.find_by_key(key)
    retval = find(:first, :conditions => ['`key_hash` = ? AND `key` = ?', calculate_key_hash(key), key])
    if retval.try(:expires_at) && retval.expires_at < Time.zone.now
      retval.destroy
      retval = nil
    end
    retval
  end
  
  # Prevent changing key once it has been set
  def key=(new_key)
    raise 'Key already set, cannot change' unless self.key.nil?
    write_attribute :key, new_key
  end

  def set_key_hash
    self.key_hash ||= KeyIndex::calculate_key_hash(self.key)
  end
  
  def type=(new_type)
    type_as_tinyint = ALLOWED_TYPES[new_type]
    raise ArgumentError if type_as_tinyint.nil?
    self.data_type = type_as_tinyint
    return new_type
  end
  
  def type
    return ALLOWED_TYPES_INVERT[self.data_type]
  end
  
  def value=(new_value)
    new_type = if new_value.is_a?(FalseClass)
      :false
    elsif new_value.is_a?(TrueClass)
      :true
    elsif new_value.is_a?(Fixnum) || new_value.is_a?(Bignum)
      :integer
    else
      new_value = new_value.to_s
      if new_value.length <= 255
        :string
      else
        :long_string
      end
    end
    self.type = new_type
    case new_type
    when :true:
      # Nothing to do, value stored in index
    when :false:
      # Nothing to do, value stored in index
    when :integer:
      if self.key_value_integer.nil?
        self.key_value_integer ||= KeyValueInteger.new(:value => new_value)
      else
        self.key_value_integer.value = new_value
      end
    when :string:
      if self.key_value_string.nil?
        self.key_value_string ||= KeyValueString.new(:value => new_value)
      else
        self.key_value_string.value = new_value
      end
    when :long_string:
      if self.key_value_long_string.nil?
        self.key_value_long_string ||= KeyValueLongString.new(:value => new_value)
      else
        self.key_value_long_string.value = new_value
      end
    end
  end
  
  def value
    case data_type
    when ALLOWED_TYPES[:false]:
      false
    when ALLOWED_TYPES[:true]:
      true
    when ALLOWED_TYPES[:integer]:
      self.key_value_integer.try(:value)
    when ALLOWED_TYPES[:string]:
      self.key_value_string.try(:value)
    when ALLOWED_TYPES[:long_string]:
      self.key_value_long_string.try(:value)
    end
  end
  
  def destroy_values_on_type_change
    if data_type_changed?
      case changes['data_type'].first
      when ALLOWED_TYPES[:false]:
        # Nothing necessary, value stored in index
      when ALLOWED_TYPES[:true]:
        # Nothing necessary, value stored in index
      when ALLOWED_TYPES[:integer]:
        key_value_integer.try(:destroy)
      when ALLOWED_TYPES[:string]:
        key_value_string.try(:destroy)
      when ALLOWED_TYPES[:long_string]:
        key_value_long_string.try(:destroy)
      end
    end
  end
  private :destroy_values_on_type_change
  
  def remove_from_cache
    Rails.cache.delete(KeyIndex::CACHE_PREFIX + self.key)
  end
  private :remove_from_cache
end
