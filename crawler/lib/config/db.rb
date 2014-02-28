require 'active_record'
module DB
  def self.checkout
    ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        host: 'localhost',
        database: 'crawler',
        username: ENV['PG_USER'],
        password: ENV['PG_PASS']
    )
  end

  def self.checkin
    ActiveRecord::Base.clear_active_connections!
  end
end

DB.checkout
DB.checkin