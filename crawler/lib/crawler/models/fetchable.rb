module Crawler
  module Models
    module Fetchable
      class FetchingError < RuntimeError
      end

      attr_accessor :fetcher_mapping, :fetcher_lambda

      # This is the method for retrieving data from vk
      # The input is id which is a single number or array.
      # In case of array it is either request for multiple fetchable models
      # or a request for one model with compound id.
      # The extraction function is in Mapping model - single for one element
      # request, muliple for multiple element request
      def fetch(id)
        return if id is [] or id.nil?
        type = (id.is_a?(Array) and not @compound_id) ? :multiple : :single

        # call for api method with args to get a response
        # specified in class definition
        response = fetcher_lambda.call(id)
        response.is_a?(Hash) && response[:error] && raise(FetchingError,
                                                          "Vk responded with error: #{response}")
        response = @fetcher_mapping[type].call(response, id) #extracting array of json models from response
        models = []
        response.each do |tuple|
          fetcher_model = new
          map_fetched_data(fetcher_model, tuple, @fetcher_mapping[:item])
          models << fetcher_model
        end
        models.count == 1 ? models[0] : models
      end

      # This method is called in class definition
      # method is api method
      # args_id_names is the name of parameter for request with id
      # could be multiple for compound ids
      # mapping are mapping parameters from mapping module
      def fetcher(method, args_id_names, mapping)
        @fetcher_mapping = mapping
        @compound_id = args_id_names.is_a?(Array) && args_id_names.count > 1
        @fetcher_lambda = lambda do |id|
          id.is_a?(Array) and not @compound_id and id = id.join(",")
          id = id.is_a?(Array) ? id : [id]
          args = mapping[:args] || {}
          args_id_names = args_id_names.is_a?(Array) ? args_id_names : [args_id_names]
          i=0
          args_id_names.each do |args_id_name|
            args.merge!({args_id_name.to_sym => id[i]})
            i+=1
          end
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
