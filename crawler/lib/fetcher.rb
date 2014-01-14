require "celluloid"
class Fetcher
  include Celluloid
  def initialize(args={})
    @socket=args[:socket]
  end

  def start
    loop do
      get_work
      request_permissions
      request_friends
      request_wall
      wait_for_responses
    end
  end

  def wait_for_responses
    collect_all_responses
    persist_data_structures
    update_frontier
  end
  
end
