class Post < ActiveRecord::Base
  has_many :likes
  has_many :likes_user_profiles, through: :likes, source: "user_profile"
  
  POSTS_NUMBER=90
  
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

  class << self
    attr_accessor :api
  end
  
  def self.fetch(args={})
    uids=args[:uids]
    args[:api] && api=args[:api]
    uids=[uids] unless uids.class.name=="Array"
    uid_posts=[]
    uids.each do |uid| 
      result=api.wall_get owner_id: uid, count: POSTS_NUMBER
      options={}
      args[:save] && options[:save]=args[:save]
      args[:min_likes] && options[:min_likes]=args[:min_likes] 
      posts=fetch_from_api_response(result, options)
      uid_posts << posts
    end
    uid_posts.compact!
    uid_posts.inject {|sum,x| sum+x}
  end
  

  def self.fetch_from_api_response(data, args={})
    raise "Error: invalid response. #{data}" unless data[:response]
    args[:min_likes]||=0
    data=data[:response]
    data.shift                  # removes count  - the structure of VK response
    results=[]
    data.each do |response|
      result=self.new
      fetch_data(result, response, Mapping)
      results << result if args[:min_likes]<=result.likes_count
    end
    results.each {|res| res.save} if args[:save]
    results.count > 1 ?  results : results[0]
  end

  def fetch_likes(args={})
    uids=fetch_like_uids
    fetched=UserProfile.where(vk_id: uids, status: 0).to_a
    fetched_uids=fetched.map(&:vk_id)
    uids.delete_if { |uid| fetched_uids.include? uid }
    profiles=args[:with_profiles] ? UserProfile.fetch(uids: uids, save: true) : uids.map {|uid| UserProfile.new(vk_id: uid) }
    likes_user_profiles.clear
    likes_user_profiles << (profiles + fetched).compact
    save
  end

  def fetch_like_uids
    data=Post.api.likes_getList owner_id: owner_id, item_id: vk_id, type: "post"             # no more than 1000 by design
    raise "Error: invalid response. #{data}" unless data[:response]
    data[:response][:users]
  end


  private

  def self.fetch_data(model, data, mapping)
    mapping.each do |key,value|
      next if data[key]==nil
      value.class.name=="Hash" ? fetch_data(model, data[key], value) : model.send("#{value}=".to_sym, data[key])
    end
  end


end

