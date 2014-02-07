require "crawler/api/tokens"
require "tempfile"


module Crawler
  module Api

    #Tokenfile structure : value, expires, vk_id
    
    describe Tokens do

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
        
        context "source argument not specified" do
          it "raises error 'Source is not specified'" do
            expect {Tokens.new}.to raise_error("Source is not specified")
          end
        end
      end

      describe "#any method" do
        it "forwards message to array of tokens" do
          tokens=Tokens.new source: __FILE__
          tokens.stub(:load)
          tokens.instance_variable_get(:@data).should_receive(:[]).with(1,2)
          tokens[1, 2]
        end

        context "when no tokens loaded and any method called" do
          it "loads the tokens from source" do
            file=make_tokens_file
            tokens=Tokens.new source: file.path
            2.times {|i| tokens[i].should==payload[i]}
            file.unlink
          end
          context "source is not available" do
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

    end

    
  end
end
