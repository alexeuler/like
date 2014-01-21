class Post < ActiveRecord::Base
  Mapping={
    uid: :vk_id,
    text: :text,
    likes:{
      count: :likes
    },
    reposts:{
      count: :reposts
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
  end
end
