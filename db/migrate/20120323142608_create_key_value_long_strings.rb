class CreateKeyValueLongStrings < ActiveRecord::Migration
  def self.up
    sql = <<SQL
    CREATE TABLE `key_value_long_strings` (
      `key_index_id` int(11) NOT NULL,
      `value` LONGTEXT COLLATE utf8_unicode_ci NOT NULL,
      PRIMARY KEY (`key_index_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
SQL
    ActiveRecord::Base.connection.execute sql
  end

  def self.down
    drop_table :key_value_long_strings
  end
end
