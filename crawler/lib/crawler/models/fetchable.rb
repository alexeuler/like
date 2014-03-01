module Crawler
  module Models
    module Fetchable
      class FetchingError < RuntimeError
      end

      attr_accessor :fetcher_mapping, :fetcher_lambda

      def fetch(id)
        response = fetcher_lambda.call(id)
        response.is_a?(Hash) && response[:error] && raise(FetchingError,
                                                          "Vk responded with error: #{response}")
        type = id.is_a?(Array) ? :multiple : :single
        response = @fetcher_mapping[type].call(response) #extracting array of models in json format
        models = []
        response.each do |tuple|
          fetcher_model = new
          map_fetched_data(fetcher_model, tuple, @fetcher_mapping[:item])
          models << fetcher_model
        end
        type == :single ? models[0] : models
      end

      def fetcher(method, args_id_name, mapping)
        @fetcher_mapping = mapping
        @fetcher_lambda = lambda do |id|
          args = mapping[:extra_args] || {}
          args.merge!({args_id_name.to_sym => id})
          api.send(method.to_sym, args)
        end
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
