class CreateImages < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE images (
      id char(36) not null,
      title varchar(255),
      file_ext varchar(255),
      file_size int,
      user_id char(36),
      collection_id char(36),
      created_at timestamp default CURRENT_TIMESTAMP,
      updated_at timestamp
    );
    SQL
    execute 'CREATE INDEX images_id ON images (id);'
    execute 'CREATE INDEX images_user_id ON images (user_id);'
    execute 'CREATE INDEX images_collection_id ON images (collection_id);'
    execute 'CREATE INDEX images_created_at ON images (created_at);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
