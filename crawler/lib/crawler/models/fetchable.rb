module Fetchable

  def fetch(args={})
    #send a call to api
    #map_data
    #the problem is what to do with multiple profiles request
  end

  private

  def map_fetched_data(data, hash)
    hash.each do |key,value|
      next if data[key]==nil
      value.class.name=="Hash" ? fetch_data(data[key], value) : send("#{value}=".to_sym, data[key])
    end
  end
end