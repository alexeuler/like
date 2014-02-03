require "crawler/api/listener"
require "spec_helper"


module Crawler
  module Api

    describe Listener do

      def pause
        sleep 0.01
      end

      def new_socket
        defaults=Listener::DEFAULTS
        TCPSocket.new(defaults[:host], defaults[:port])  
      end
      
      before(:all) do
        @listener=Listener.new #scheduler is specified later as doubles don't work in before :all
      end

      before(:each) do
        @async=double("async")
        @listener.instance_variable_set(:@scheduler, double("scheduler"))
        @scheduler=@listener.instance_variable_get(:@scheduler)
        @scheduler.stub(:async).and_return(@async.as_null_object)
        unless @listener.active
          @listener.async.start
          pause
        end
      end
      
      
      describe "#new" do
        it "Starts new server on #{Listener::DEFAULTS[:host]}:#{Listener::DEFAULTS[:port]} with scheduler argument as DI" do
        end

        context "When incoming connetction" do
          it "Calls scheduler.async.push({socket: celluloid_socket})" do
            @scheduler.should_receive(:async).twice.and_return(@async)
            @async.should_receive(:push).with({socket: an_instance_of(Celluloid::IO::TCPSocket)}).twice
            2.times {new_socket}
            pause
          end
        end
      end

      describe "#stop" do
        
        context "when server is active" do
          it "stops the server" do
            @listener.stop
            pause
            @scheduler.should_not_receive(:async)
            new_socket
            pause
          end
        end

        context "when server is inactive" do
          it "does nothing" do
            2.times {@listener.stop}
            pause
            @scheduler.should_not_receive(:async)
            new_socket
            pause
          end
        end
        
      end


      describe "#async.start" do
        
        context "when server is active" do
          it "does nothing" do
            @listener.stop
            pause
            @scheduler.should_receive(:async)
            2.times {@listener.async.start}
            pause
            new_socket
            pause
          end
        end

        context "when server is inactive" do
          it "activates the server" do
            @listener.stop
            pause
            @scheduler.should_receive(:async)
            @listener.async.start
            pause
            new_socket
            pause
          end
        end
        
      end

      
    end
  end
end
