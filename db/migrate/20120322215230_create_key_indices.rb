class CreateKeyIndices < ActiveRecord::Migration
  def self.up
    sql = <<SQL
    CREATE TABLE `key_indices` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
      `key_hash` binary(16) NOT NULL,
      `data_type` tinyint(3) unsigned NOT NULL,
      `expires_at` datetime DEFAULT NULL,
      `created_at` datetime DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
SQL
    ActiveRecord::Base.connection.execute sql
    
    add_index :key_indices, :key_hash
    add_index :key_indices, :key, :unique => true
    add_index :key_indices, :expires_at
  end

  def self.down
    drop_table :key_indices
  end
end
