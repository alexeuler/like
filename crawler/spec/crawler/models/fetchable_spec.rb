require 'crawler/models/fetchable'

module Crawler
  module Models

    class Model

      attr_accessor :full_name, :city, :country

      MAPPING ={
          item: {
              name: "full_name",
              location: {
                  country: "country",
                  city: "city"
              }
          },
          single: lambda {|x| [x]},
          multiple: lambda {|x| x}
      }
      extend Fetchable
      fetcher :users_get, :uids, MAPPING

    end

    describe Fetchable do
      before(:each) do
        @api=double("api")
        Thread.current[:api] = @api
      end

      describe "#fetch" do
        it "calls the api and transforms the results into the model" do
          @api.should_receive(:users_get).with({uids: "id"}) do
            {name: "Robot",
             location: {
                 country: "Russia",
                 city: "Moscow",
                 town: "Whatever"
             }
            }
          end
          Model.any_instance.should_not_receive(:town=)
          model = Model.fetch("id")
          model.full_name.should == "Robot"
          model.country.should == "Russia"
          model.city.should == "Moscow"
        end

      end

    end

  end
end