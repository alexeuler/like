def require_dir(dir)
  Dir[File.dirname(__FILE__) + "/../#{dir}/*.rb"].each {|file| require file }
end

require "active_record"
require "mysql2"
require_dir "models"

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  database: 'crawler',
  username: 'root',
  password: ENV['MY_SQL_PASS']
)
