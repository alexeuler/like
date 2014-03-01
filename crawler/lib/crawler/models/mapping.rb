module Crawler
  module Models
    module Mapping
      def self.user_profile
        {
            item: {
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
                    albums: :albums_count,
                    videos: :videos_count,
                    audios: :audios_count,
                    notes: :notes_count,
                    photos: :photos_count,
                    groups: :groups_count,
                    friends: :friends_count,
                    online_friends: :online_friends_count,
                    user_videos: :user_videos_count,
                    followers: :followers_count
                }
            },
            single: lambda {|x| x},
            multiple: lambda {|x| x},
            args: {
                fields: "uid,first_name,last_name,nickname,screen_name,"\
                            "sex,bdate,city,country,timezone,photo,photo_medium,"\
                            "photo_big,has_mobile,rate,contacts,education,online,counters"
            }
        }
      end
    end
  end
end