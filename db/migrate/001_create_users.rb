class CreateUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE users (
      id char(36) not null,
      email varchar(255) not null,
      password varchar(255) not null,
      active int not null default 0,
      created_at timestamp default CURRENT_TIMESTAMP,
      updated_at timestamp
    );
    SQL
    execute 'CREATE INDEX users_id ON users (id);'
    execute 'CREATE UNIQUE INDEX users_email ON users (email);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
