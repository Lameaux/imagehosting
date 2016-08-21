class CreateCollections < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE collections (
      id char(36) not null,
      title varchar(255),
      user_id char(36),
      created_at timestamp default CURRENT_TIMESTAMP,
      updated_at timestamp
    );
    SQL
    execute 'CREATE INDEX collections_id ON collections (id);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
