class CreateImages < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE images (
      id char(36) not null,
      title text,
      file_ext varchar(255),
      user_id char(36)
    );
    SQL
    execute 'CREATE INDEX images_id ON images (id);'
    execute 'CREATE INDEX images_user_id ON images (user_id);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
