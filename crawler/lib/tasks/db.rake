require File.expand_path("../config/db", File.dirname(__FILE__))

db_namespace=namespace :db do

  task :environment do
    DB.checkout
    ActiveRecord::Migrator.migrations_paths=
        File.expand_path("../crawler/models/migrations", File.dirname(__FILE__))
  end

  desc "create database"
  task :create => :environment do
    begin
      ActiveRecord::Tasks::DatabaseTasks.create_current
    ensure
      DB.checkin
    end
  end

  desc "drop database"
  task :drop => :environment do
    begin
      ActiveRecord::Tasks::DatabaseTasks.create_current
    ensure
      DB.checkin
    end
  end

  desc "reset database"
  task :reset => ['db:drop', 'db:create', 'db:migrate']

  desc "runs pending migrations"
  task :migrate => :environment do
    begin
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
      db_namespace['dump'].invoke
    ensure
      DB.checkin
    end
  end

  desc "rolls back the last migraion"
  task :rollback => :environment do
    begin
      ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, 1)
      db_namespace['dump'].invoke
    ensure
      DB.checkin
    end
  end

  task :dump => :environment do
    begin
      require 'active_record/schema_dumper'
      filename = File.join(ActiveRecord::Migrator.migrations_paths, 'schema.rb')
      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
      db_namespace['dump'].reenable
    ensure
      DB.checkin
    end
  end

  desc "creates the migration specified by arg"
  task :migration, [:name] => [:environment] do |task, args|
    begin
      file_name = "#{ActiveRecord::Migrator.migrations_paths[0]}/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{args.name}.rb"
      file=File.new(file_name, "w")
      file.puts("class #{args.name.split('_').each { |s| s.capitalize! }.join('')} < ActiveRecord::Migration")
      file.puts("  def change")
      file.puts
      file.puts("  end")
      file.puts("end")
      file.close
    ensure
      DB.checkin
    end
  end
end
