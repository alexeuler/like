require "net/http"
require "json"
require "crawler/api/server"


module Crawler
  module Api

    class HttpDouble
      class << self
        attr_accessor :count, :log

        def min_interval
          res = 9999
          time_old = 0
          log.each do |lg|
            if lg[:time] - time_old < res
              res = lg[:time] - time_old
            end
            time_old = lg[:time]
          end
          res
        end

      end

      def initialize
        @count = self.class.count
        self.class.count+=1
        self.class.log << {time: Time.now.to_f, id: @count}
      end

      def body
        {double: @count}.to_json
      end
    end

    describe Server, focus: true do

      before(:all) do
        @token_filename=make_tokens
        @server=Server.new token_filename: @token_filename
        @server.async.start
        sleep 1
      end

      before(:each) do
        HttpDouble.count = 0
        HttpDouble.log = []
        Net::HTTP.stub(:get_response) do
          HttpDouble.new
        end

      end

      def make_tokens (number=1)
        token_file=Tempfile.new('tokens')
        number.times { |i| token_file.puts("#{i};#{Time.now.to_i+100};1") }
        token_file.close
        token_file.path
      end

      def update_tokens (filename, number=1)
        File.open(filename, "w") do |f|
          number.times { |i| f.puts("#{i};#{Time.now.to_i+100};1") }
        end
      end

      it "receives one request and returns one response" do
        socket=TCPSocket.new "localhost", 9000
        socket.puts({method: "users_get"}.to_json)
        response = socket.gets.chomp
        response = JSON.parse response, symbolize_names: true
        response.should == {double: 0, incoming: {method: "users_get"}.to_json}
        socket.close
      end

      context "when one token available" do
        it "receives many requests through one socket and returns responses with 1/3 frequency" do
          socket=TCPSocket.new "localhost", 9000
          10.times { socket.puts({method: "users_get"}.to_json) }
          10.times do
            response = socket.gets.chomp
            response = JSON.parse response, symbolize_names: true
            response[:double].should_not be_nil
            response[:error].should be_nil
          end
          HttpDouble.min_interval.should <= 1.0 / 3 + 0.03
          HttpDouble.min_interval.should >= 1.0 / 3
          socket.close
        end

        it "receives many requests via many sockets and returns responses with 1/3 frequency" do
          sockets = []
          10.times { sockets << TCPSocket.new("localhost", 9000) }
          10.times { |i| sockets[i].puts({method: "users_get"}.to_json) }
          10.times do |i|
            response = sockets[i].gets.chomp
            response = JSON.parse response, symbolize_names: true
            response[:double].should_not be_nil
            response[:error].should be_nil
          end
          HttpDouble.min_interval.should <= 1.0 / 3 + 0.03
          HttpDouble.min_interval.should >= 1.0 / 3
          10.times do |i|
            sockets[i].close
          end
        end
      end

      context "when 2 tokens are available" do
        before :each do
          update_tokens(@token_filename, 2)
        end

        it "increases the request speed twice" do
          socket=TCPSocket.new "localhost", 9000
          10.times { socket.puts({method: "users_get"}.to_json) }
          10.times do
            response = socket.gets.chomp
            response = JSON.parse response, symbolize_names: true
            response[:double].should_not be_nil
            response[:error].should be_nil
          end
          HttpDouble.min_interval.should <= 1.0 / 5
          puts HttpDouble.log
          socket.close
        end
      end
    end
  end
end

