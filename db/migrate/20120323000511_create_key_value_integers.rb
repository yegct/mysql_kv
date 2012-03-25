class CreateKeyValueIntegers < ActiveRecord::Migration
  def self.up
    sql = <<SQL
    CREATE TABLE `key_value_integers` (
      `key_index_id` int(11) NOT NULL,
      `value` bigint(20) NOT NULL,
      PRIMARY KEY (`key_index_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
SQL
    ActiveRecord::Base.connection.execute sql
  end

  def self.down
    drop_table :key_value_integers
  end
end
