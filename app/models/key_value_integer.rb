class KeyValueInteger < ActiveRecord::Base
  set_primary_key :key_index_id
  belongs_to :key_index
end
