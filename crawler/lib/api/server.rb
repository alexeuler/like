require_relative "listener"
require_relative "scheduler"
require_relative "manager"
require_relative "requester"

module Api

  # This is the main class that starts api daemon at localhost:9000
  # You connect to server via TCP socket, write a JSON request, e.g. {method: "users.get", params: {uid: 444, v:5}}
  # Then you can issue the next request
  # Each request is marked with id, starting with 1
  # Then w8 for response from the socket which comes in native json from vk, but with request id added, e.g. {response: {...}, id: 1}
  #----------
  # Known issues:
  # Request sometimes fails as too many reqs per sec (approx 1 in 60) due to concurency issues. This can be fixed by adding delay between reqeusts.
  # The other thing is when tokens are updated some failures will arise
  # So make sure you do some retries on the client side
  #----------
  # Tokens are stored in tokens / tokens.csv
  # To manage tokens go to tokens dir and launch rackup

  class Server
    def self.start
      Celluloid.logger = nil
      Scheduler.request_queue=Manager.request_queue=Queue.new
      scheduler=Scheduler.pool size: 20 #up to 20 simultaneous connections
      listener=Listener.new host: "localhost", port: 9000, scheduler: scheduler
      listener.async.start
      requester=Requester.pool size: 50 #these require heavy IO
      manager=Manager.new token_filename: File.expand_path(File.dirname(__FILE__)+"/tokens/tokens.csv"), server_requests_per_sec: 20, id_requests_per_sec: 3, requester: requester # server requests per sec seems to be unlimited
      manager.async.start
    end
  end
end

