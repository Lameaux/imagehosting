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
      album_index int default 0,
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
    execute 'CREATE INDEX images_likes ON images (likes);'
    execute 'CREATE INDEX images_file_ext ON images (file_ext);'
    execute 'CREATE INDEX images_width ON images (width);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
