module Crawler
  module Models
    module Mapping
      def self.user_profile
        {
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
            },
            multiple: 0,
            extra_args: {
                fields: "uid,first_name,last_name,nickname,screen_name,
                            sex,bdate,city,country,timezone,photo,photo_medium,
                            photo_big,has_mobile,rate,contacts,education,online,counters"
            }
        }
      end
    end
  end
end