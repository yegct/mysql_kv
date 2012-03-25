class KeyIndex < ActiveRecord::Base
  ALLOWED_TYPES = {
    :nil => 0,
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
  
  # Prevent changing key once it has been set
  def key=(new_key)
    raise 'Key already set, cannot change' unless self.key.nil?
    write_attribute :key, new_key
  end

  def set_key_hash
    self.key_hash ||= KeyIndex::calculate_key_hash(self.key)
  end
  
  def self.calculate_key_hash(key)
    Digest::MD5.digest(key)
  end
  
  def self.find_by_key(key)
    find(:first, :conditions => ['`key_hash` = ? AND `key` = ?', calculate_key_hash(key), key])
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
end
