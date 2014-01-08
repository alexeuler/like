module Api
  class Tuple
    attr_accessor :socket, :request, :response
    def initialize(args={})
      @socket=args[:socket]
      @request=args[:request]
      @response=args[:response]
    end
  end
end
