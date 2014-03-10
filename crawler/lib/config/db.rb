require 'active_record'
ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    host: 'localhost',
    database: 'crawler',
    username: ENV['PG_USER'],
    password: ENV['PG_PASS'],
    reaping_frequency: 10,
    pool: 5
)

module DB
  def self.checkout

  end

  def self.checkin
    ActiveRecord::Base.clear_active_connections!
  end
end
