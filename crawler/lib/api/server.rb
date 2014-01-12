require_relative "listener"
require_relative "scheduler"
require_relative "manager"
require_relative "requester"

module Api
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

