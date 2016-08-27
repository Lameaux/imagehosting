class CreateAlbums < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE albums (
      id char(36) not null,
      title varchar(255),
      user_id char(36),
      created_at timestamp default CURRENT_TIMESTAMP,
      updated_at timestamp
    );
    SQL
    execute 'CREATE INDEX albums_id ON albums (id);'
    execute 'CREATE INDEX albums_user_id ON albums (user_id);'
    execute 'CREATE INDEX albums_created_at ON albums (created_at);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
