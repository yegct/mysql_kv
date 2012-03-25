class KeyValueString < ActiveRecord::Base
  set_primary_key :key_index_id
  belongs_to :key_index
  validates_length_of :value, :maximum => 255
end
