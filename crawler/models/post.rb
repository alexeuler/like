class Post < ActiveRecord::Base
  Mapping={
    id: :vk_id,
    to_id: :owner_id,
    text: :text,
    date: :date,
    copy_owner_id: :copy_owner_id,
    copy_post_id: :copy_post_id,
    likes:{
      count: :likes_count
    },
    reposts:{
      count: :reposts_count
    },
    attachment:{
      type: :attachment_type,
      video:{
        vid: :attachment_id,
        owner_id: :attachment_owner_id,
        title: :attachment_title,
        description: :attachment_text,
        image: :attachment_image
      },
      link:{
        title: :attachment_title,
        description: :attachment_text,
        image_src: :attachment_image,
        url: :attachment_url
      },
      photo:{
        pid: :attachment_id,
        owner_id: :attachment_owner_id,
        title: :attachment_title,
        description: :attachment_text,
        src: :attachment_image
      }
    }
  }

  def self.fetch_from_api_response(data, args={})
    raise "Error: invalid response. #{data}" unless data[:response]
    data=data[:response]
    results=[]
    data.each do |response|
      result=self.new
      fetch_data(result, response, Mapping)
      results << result
    end
    results.count > 1 ?  results : results[0]
  end

  private

  def self.fetch_data(model, data, mapping)
    mapping.each do |key,value|
      next if data[key]==nil
      value.class.name=="Hash" ? fetch_data(model, data[key], value) : model.send("#{value}=".to_sym, data[key])
    end
  end
  
end

