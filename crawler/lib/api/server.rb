require_relative "listener"
require_relative "scheduler"
require_relative "manager"
require_relative "requester"

module Api
  class Server
    def self.start
      Scheduler.request_queue=Manager.request_queue=Queue.new
      scheduler=Scheduler.pool size: 10 #these threads are fast
      listener=Listener.new host: "localhost", port: 9000, scheduler: scheduler
      listener.async.start
      requester=Requester.pool size: 50 #there require heavy IO
      manager=Manager.new token_filename: File.expand_path(File.dirname(__FILE__)+"/tokens.csv"), server_requests_per_sec: 5, id_requests_per_sec: 3, requester: requester
      manager.async.start
    end
  end
end

