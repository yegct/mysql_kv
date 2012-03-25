class CreateKeyValueStrings < ActiveRecord::Migration
  def self.up
    sql = <<SQL
    CREATE TABLE `key_value_strings` (
      `key_index_id` int(11) NOT NULL,
      `value` VARCHAR(255) NOT NULL,
      PRIMARY KEY (`key_index_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
SQL
    ActiveRecord::Base.connection.execute sql
  end

  def self.down
    drop_table :key_value_strings
  end
end
