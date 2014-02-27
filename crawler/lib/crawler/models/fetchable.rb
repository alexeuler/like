module Crawler
  module Models
    module Fetchable

      attr_accessor :fetcher_mapping, :fetcher_lambda

      def fetch(id)
        response = fetcher_lambda.call(id)
        fetcher_model = new
        map_fetched_data(fetcher_model, response, fetcher_mapping)
        fetcher_model
      end

      def fetcher(method, args_name, mapping)
        @fetcher_mapping = mapping
        @fetcher_lambda = lambda { |id| api.send(method.to_sym, {args_name.to_sym => id}) }
      end

      private

      def api
        Thread.current[:api]
      end

      def map_fetched_data(model, data, mapping)
        mapping.each do |key, value|
          next if data[key]==nil
          value.class.name=="Hash" ? map_fetched_data(model, data[key], value)
          : model.send("#{value}=".to_sym, data[key])
        end
      end
    end
  end
end
