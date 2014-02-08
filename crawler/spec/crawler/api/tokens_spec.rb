require "crawler/api/tokens"
require "tempfile"


module Crawler
  module Api

    #Tokenfile structure : value, expires, vk_id
    
    describe Tokens do
      
      let :payload do
        res=[]
        timestamp=Time.now
        res << {value: "sfh6d", expires: timestamp+60*60*24, id: "id1"}
        res << {value: "dsjflsdjflkds", expires: timestamp+60*60*24, id: "id2"}
        res << {value: "dgfdg", expires: timestamp-1, id: "id3"}
        res
      end
      
      def make_tokens_file(filename="tokens")
        file=Tempfile.new(filename)
        payload.each { |p| file.puts "#{p[:value]};#{p[:expires].to_i};#{p[:id]}"}
        file.close
        file
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
        
        
        context "when no tokens loaded and any method called" do
          it "loads the tokens from source and discards expired tokens" do
            timestamp=Time.now
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            tokens.count.should==payload.count-1
            tokens.count.times do |i|
              tokens[i].delete(:expires).to_i.should == payload[i][:expires].to_i
              tokens[i].delete(:last_used).should < Time.now
              tokens[i].keys.each {|key| tokens[i][key].should == payload[i][key]}
            end
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
          it "loads the tokens from source and discards expired tokens" do
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

      describe "#last_used" do
        it "returns the lastest :last_used" do
          file=make_tokens_file
          tokens=Tokens.new source: file.path
          tokens.last_used.should == tokens.last[:last_used]
        end
      end

      
      describe "#pick" do
        it "picks the oldest (by :last_used) token" do
          file=make_tokens_file
          tokens=Tokens.new source: file.path
          tokens.pick[:value].should == payload[0][:value]
        end
      end

      describe "#touch(token)" do
        it "sets last_used of token to Time.now" do
          token={last_used: Time.now}
          timestamp=Time.now+99
          Time.stub(:now).and_return(timestamp)
          tokens=Tokens.new source: ""
          tokens.touch(token)
          token[:last_used].should == timestamp
        end
      end
    end
  end
end


