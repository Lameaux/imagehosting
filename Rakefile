# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc 'Drops all tables'
task :drop_tables => :environment do
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("drop table #{table} cascade")
  end
end
