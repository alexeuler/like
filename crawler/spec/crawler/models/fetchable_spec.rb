require 'crawler/models/fetchable'

module Crawler
  module Models

    class Model

      MAPPING = {
          name: "full_name",
          location: {
              country: "Russia",
              city: "Moscow"
          }
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
            Model.should_receive(:name=).with("Robot")
            Model.should_receive(:country=).with("Russia")
            Model.should_receive(:city=).with("Moscow")
            Model.should_not_receive(:town)
          end
          Model.fetch("id")

        end

      end

    end

  end
end