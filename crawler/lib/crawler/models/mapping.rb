module Crawler
  module Models
    module Mapping
      user_profile = {
          single: {
              uid: :vk_id,
              first_name: :first_name,
              last_name: :last_name,
              photo: :photo,
              sex: :sex,
              bdate: :birthday,
              university: :university,
              faculty: :faculty,
              city: :city,
              country: :country,
              has_mobile: :has_mobile,
              counters: {
                  albums: :albums,
                  videos: :videos,
                  audios: :audios,
                  notes: :notes,
                  photos: :photos,
                  groups: :groups,
                  friends: :friends,
                  online_friends: :online_friends,
                  user_videos: :user_videos,
                  followers: :followers
              }
          }
      }
    end
  end
end