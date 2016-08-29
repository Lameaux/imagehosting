class CreateUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE users (
      id char(36) not null,
      username varchar(255) not null,
      email varchar(255) not null,
      password_digest varchar(255),
      activation_code varchar(36),
      reset_code varchar(36),
      active int default 0,
      created_at timestamp default CURRENT_TIMESTAMP,
      updated_at timestamp
    );
    SQL
    execute 'CREATE INDEX users_id ON users (id);'
    execute 'CREATE UNIQUE INDEX users_username ON users (username);'
    execute 'CREATE UNIQUE INDEX users_email ON users (email);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
