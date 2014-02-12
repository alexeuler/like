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

      describe "#last_used" do
        context "data loaded" do
          it "returns the lastest :last_used" do
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            tokens.pick
            tokens.last_used.should == tokens.instance_variable_get(:@data).last[:last_used]
          end
        end
        context "data is not loaded" do
          it "returns a time more than 12 hours ago" do
            tokens=Tokens.new source: ""
            tokens.last_used.should <= Time.now - 12*60*60
          end
        end
      end

      
      describe "#pick" do
        context "tokens are loaded and token file is up-to-date" do
          it "picks the oldest (by :last_used) token" do
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            tokens.pick[:value].should == payload[0][:value]
          end
        end

        context "when data is not loaded" do
          it "loads the tokens from source and discards expired tokens" do
            timestamp=Time.now
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            tokens.pick
            data=tokens.instance_variable_get(:@data)
            data.count.should==payload.count-1
            data.count.times do |i|
              data[i].delete(:expires).to_i.should == payload[i][:expires].to_i
              data[i].delete(:last_used).should < Time.now
              data[i].keys.each {|key| data[i][key].should == payload[i][key]}
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
            tokens.pick
            file.unlink

            sleep 0.01
            
            tokens.should_receive(:load)
            file=make_tokens_file("tokens1")
            tokens.source=file.path
            tokens.pick
            file.unlink
          end
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


