module Crawler
  module Models
    module Fetchable

      attr_accessor :fetcher_mapping, :fetcher_lambda

      def fetch(id)
        models = []
        mapping = @fetcher_mapping[:single]
        response = fetcher_lambda.call(id)
        response = [response] unless response.is_a?(Array)
        i=-1
        response.each do |tuple|
          i+=1
          next if i < fetcher_mapping[:multiple]
          fetcher_model = new
          map_fetched_data(fetcher_model, tuple, mapping)
          models << fetcher_model
        end
        models.count == 1 ? models[0] : models
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
