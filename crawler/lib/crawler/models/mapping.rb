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
            single: lambda { |x, id| x },
            multiple: lambda { |x, id| x },
            args: {
                fields: "uid,first_name,last_name,nickname,screen_name,"\
                            "sex,bdate,city,country,timezone,photo,photo_medium,"\
                            "photo_big,has_mobile,rate,contacts,education,online,counters"
            }
        }
      end

      def self.post
        {
            item: {
                id: :vk_id,
                to_id: :owner_id,
                text: :text,
                date: :date,
                copy_owner_id: :copy_owner_id,
                copy_post_id: :copy_post_id,
                likes: {
                    count: :likes_count
                },
                reposts: {
                    count: :reposts_count
                },
                attachment: {
                    type: :attachment_type,
                    video: {
                        vid: :attachment_id,
                        owner_id: :attachment_owner_id,
                        title: :attachment_title,
                        description: :attachment_text,
                        image: :attachment_image
                    },
                    link: {
                        title: :attachment_title,
                        description: :attachment_text,
                        image_src: :attachment_image,
                        url: :attachment_url
                    },
                    photo: {
                        pid: :attachment_id,
                        owner_id: :attachment_owner_id,
                        title: :attachment_title,
                        description: :attachment_text,
                        src: :attachment_image
                    }
                }
            },
            single: lambda do |x, id|
              x.shift
              x
            end,
            args: {count: 100}
        }
      end

      def self.like
        {
            item:
                {post_id: "post_id",
                 user_profile_id: "user_profile_id"
                },
            single: lambda do |x, id|
              data = x[:users]
              existing_models = UserProfile.where(vk_id: data).to_a
              existing = existing_models.map(&:vk_id)
              new =data - existing
              new_models = UserProfile.fetch(new)
              models = new_models + existing_models
              post = Post.where(vk_id: id[0], owner_id: id[1]).first
              post.likes_user_profiles = models
              []
            end,
            args:{
                type: "post"
            }

        }
      end
    end
  end
end