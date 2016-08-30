class CreateImages < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE images (
      id char(36) not null,
      title varchar(255),
      tags varchar(255),
      description text,
      file_ext char(3),
      file_size int,
      width int,
      height int,
      user_id char(36) not null,
      album_id char(36) not null,
      hidden int default 0,
      views int default 0,
      likes int default 0,
      created_at timestamp default CURRENT_TIMESTAMP,
      updated_at timestamp
    );
    SQL
    execute 'CREATE INDEX images_id ON images (id);'
    execute 'CREATE INDEX images_user_id ON images (user_id);'
    execute 'CREATE INDEX images_album_id ON images (album_id);'
    execute 'CREATE INDEX images_created_at ON images (created_at);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
