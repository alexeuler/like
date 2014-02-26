require 'rspec'
require 'spec_helper'
require 'crawler/vk_api'

module Crawler
  describe VkApi do

    context "new" do
      it "sets Thread[:api] to self" do
        @client, @server = socket_pair
        @api=VkApi.new socket: @client
        Thread.current[:api].should == @api
        @client.close
        @server.close
      end
    end

    context "when any method is called" do
      before :each do
        @client, @server = socket_pair
        @api=VkApi.new socket: @client
      end
      after :each do
        @client.close
        @server.close
      end

      it 'replaces . with _ and sends the request to socket in api format' do
        @server.puts({response: "Test"}.to_json)
        @api.users_get(uid: [1, 2, 3]).should == {response: "Test"}
        response = @server.gets.chomp
        response.should == {method: "users.get", params: {uid: [1, 2, 3]}}.to_json
      end

      context "when api doesn't respond in #{VkApi::DEFAULTS[:timeout]} seconds" do
        it "raises SocketError" do
          @api.timeout=0.1
          expect { @api.users_get(uid: [1, 2, 3]) }.to raise_error(VkApi::SocketError)
        end
      end

      context "when socket is not specified" do
        it "raises SocketError" do
          @api.socket=nil
          expect { @api.users_get(uid: [1, 2, 3]) }.to raise_error(VkApi::SocketError)
        end
      end

      context "when response is not in json format" do
        it "raises InvalidResponse error" do
          @server.puts("response = Test")
          expect {@api.users_get(uid: [1, 2, 3])}.to raise_error(VkApi::InvalidResponse)
        end
      end

    end
  end
end
