require 'active_record'
require 'mysql2'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  database: 'crawler',
  username: 'root',
  password: ENV['MY_SQL_PASS']
)
