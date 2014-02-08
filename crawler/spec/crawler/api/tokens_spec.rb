require "crawler/api/tokens"
require "tempfile"


module Crawler
  module Api

    #Tokenfile structure : value, expires, vk_id
    
    describe Tokens, focus: true do

      def make_tokens_file(filename="tokens")
        file=Tempfile.new(filename)
        payload.each {|p| file.puts "#{p[:value]};#{p[:expires].to_i};#{p[:id]}"}
        file.close
        file
      end

      def payload
        res=[]
        res << {value: "sfh6d", expires: Time.new(2012,1,2,4,5,6), id: "id1"}
        res << {value: "dsjflsdjflkds", expires: Time.new(2012,1,2,4,5,7), id: "id2"}
        res
      end

      
      describe "#new(source: <filename>)" do
        it "initializes new tokens object with the tokens source specified by filename" do
          tokens=Tokens.new(source: __FILE__)
          tokens.source.should == __FILE__
        end
        
        context "when source argument not specified" do
          it "raises error 'Source is not specified'" do
            expect {Tokens.new}.to raise_error("Source is not specified")
          end
        end
      end

      describe "#any other method" do
        it "forwards message to array of tokens" do
          tokens=Tokens.new source: __FILE__
          tokens.stub(:load)
          tokens.instance_variable_get(:@data).should_receive(:[]).with(1,2)
          tokens[1, 2]
        end

        context "when no tokens loaded and any method called" do
          it "loads the tokens from source" do
            timestamp=Time.now
            Time.stub(:now).and_return(timestamp)
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            2.times {|i| tokens[i].should==payload[i].merge({last_used: timestamp})}
            file.unlink
          end
          context "when source is not available" do
            it "raises error" do
              tokens=Tokens.new source: "whatever file"
              expect {tokens[0]}.to raise_error
            end
          end
        end

        context "when the source file has been modified and any method called" do
          it "loads the tokens from source" do
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            tokens[0] #to call load
            file.unlink

            sleep 0.01
            
            tokens.should_receive(:load)
            file=make_tokens_file("tokens1")
            tokens.source=file.path
            tokens[0] #to call load
            file.unlink
          end
        end

        context "otherwise" do
          it "does not call load" do
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            tokens[0] #to call load
            tokens.should_not_receive(:load)
            tokens[0]
          end
        end
        
      end

      describe "#pick" do
        it "picks the oldest (by :last_used) token" do
          file=make_tokens_file
          tokens=Tokens.new source: file.path
          tokens.pick[:value].should == payload[0][:value]
        end
      end

      describe "#extract(token)" do
        it "sets last_used of token to Time.now and returns the token value" do
          token={value: "123", last_used: Time.now}
          timestamp=Time.now+99
          Time.stub(:now).and_return(timestamp)
          tokens=Tokens.new source: ""
          tokens.extract(token).should == "123"
          token[:last_used].should == timestamp
        end
      end
    end

    
  end
end
