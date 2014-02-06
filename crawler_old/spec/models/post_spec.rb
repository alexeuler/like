require "config/active_record"
require "post"
require "like"
POSTS={
  body:{
    :id=>333,
    :from_id=>252,
    :to_id=>252,
    :date=>1387542029,
    :post_type=>"copy",
    :text=>"text!!!",
    :copy_post_date=>1387535605,
    :copy_post_type=>"post",
    :copy_owner_id=>129244038,
    :copy_post_id=>17014,
    :can_delete=>1,
    :likes=>{:count=>20},
    :reposts=>{:count=>30}
  },
  video:
  {
    :type=>"video",
    :video=>{
      :vid=>167941262,
      :owner_id=>-46172262,
      :title=>"The video",
      :duration=>20,
      :description=>"Yan Voytikhov<br>https://vk.com/coub_vk",
      :date=>1388089960,
      :views=>18046,
      :image=>"http://cs617529.vk.me/u10115843/video/l_39a5077c.jpg",
      :image_big=>"http://cs617529.vk.me/u10115843/video/l_39a5077c.jpg",
      :image_small=>"http://cs617529.vk.me/u10115843/video/s_9fe10ee8.jpg",
      :image_xbig=>"http://cs617529.vk.me/u10115843/video/y_d2eeed72.jpg",
      :access_key=>"a100b1910675a446b8"
    }
  },
  photo:{
    :type=>"photo",
    :photo=>{
      :pid=>317588824,
      :aid=>-7,
      :owner_id=>129244038,
      :src=>"http://cs7010.vk.me/c7008/v7008038/efe5/dHMVvPn0d1Q.jpg",
      :src_big=>"http://cs7010.vk.me/c7008/v7008038/efe6/iigMw_ZPPzw.jpg",
      :src_small=>"http://cs7010.vk.me/c7008/v7008038/efe4/zRwHaQhrXWk.jpg",
      :width=>337,
      :height=>253,
      :text=>"",
      :created=>1387535603,
      :post_id=>170140,
      :access_key=>"8f5806b79f8a9b0bcc"
    }
  },
  link:{
    :type=>"link",
    :link=>{
      :url=>"http://habrahabr.ru/post/207508/",
      :title=>"Iron Maiden",
      :description=>"Desc",
      :preview_page=>"2021091085_1833155287",
      :preview_url=>"http://m.vk.com/article2021091085_1833155287?api_view=032a6e948999831035d8e29b5c4813"}
  } 
}

MODELS={
  video:{
    vk_id: 333,      
    owner_id: 252,
    date: 1387542029,
    text: "text!!!",
    :copy_owner_id=>129244038,
    :copy_post_id=>17014,
    attachment_type: "video",
    attachment_image: "http://cs617529.vk.me/u10115843/video/l_39a5077c.jpg",
    attachment_text: "Yan Voytikhov<br>https://vk.com/coub_vk",
    attachment_url: nil,
    likes_count: 20,               
    reposts_count: 30,       
    attachment_id: 167941262,
    attachment_owner_id: -46172262,
    attachment_title: "The video"
  },
  photo:{
    vk_id: 333,      
    owner_id: 252,
    date: 1387542029,
    text: "text!!!",
    :copy_owner_id=>129244038,
    :copy_post_id=>17014,
    attachment_type: "photo",
    attachment_image: "http://cs7010.vk.me/c7008/v7008038/efe5/dHMVvPn0d1Q.jpg",
    attachment_text: nil,
    attachment_url: nil,
    likes_count: 20,               
    reposts_count: 30,       
    attachment_id: 317588824,
    attachment_owner_id: 129244038,
    attachment_title: nil
  },
  link:{
    vk_id: 333,      
    owner_id: 252,
    date: 1387542029,
    text: "text!!!",
    :copy_owner_id=>129244038,
    :copy_post_id=>17014,
    attachment_type: "link",
    attachment_image: nil,
    attachment_text: "Desc",
    attachment_url: "http://habrahabr.ru/post/207508/",
    likes_count: 20,               
    reposts_count: 30,       
    attachment_id: nil,
    attachment_owner_id: nil,
    attachment_title: "Iron Maiden"
  }

}

def make_sample(name)
  res=POSTS[:body].clone
  res[:attachment]=POSTS[name.to_sym]
  res
end

describe Post do
  context "::fecth_from_api_response" do
    it "creates new Posts with filled attributes from vk wall.get" do
      attachs=[:video, :photo, :link]
      samples=attachs.map {|x| make_sample(x)}
      samples.unshift 3         # count - the structure of VK response
      posts=Post.fetch_from_api_response({response: samples})
      i=0
      attachs.each do |name| 
        MODELS[name].each do |key,value| 
          posts[i][key].should==value
        end
        i+=1
      end
    end

    context "::fetch_from_api_response(response, save: true)" do
      it "persists the object" do
        Post.fetch_from_api_response({response: [2,{id: 1, to_id: 1},{id: 2, to_id: 2}]}, save: true)
        Post.all.count.should==2
      end
    end

    context "::fetch_from_api_response(response, save: true, min_likes: 2)" do
      it "persists the object if likes >= 2", now: true do
        Post.fetch_from_api_response({response: [2,{id: 1, to_id: 1, likes: {count: 3}},{id: 2, to_id: 2}]}, save: true, min_likes: 2)
        Post.all.count.should==1
      end
    end

    
  end

  context "::fetch" do
    before :each do
      @api=double("api")
    end
    
    it "fecthes users wall posts from vk specified by uids parameter" do
      @api.should_receive(:wall_get).with({owner_id: 1, count: Post::POSTS_NUMBER}).exactly(3).times.and_return("test")
      Post.should_receive(:fetch_from_api_response).with("test", {}).exactly(3).times.and_return([1,2])
      Post.fetch(uids: [1,1,1], api: @api).should==[1,2,1,2,1,2]
    end

    context "::fetch(uids:1, save: true)" do
      it "persists the object" do
        @api.should_receive(:wall_get).with({owner_id: 1, count: Post::POSTS_NUMBER}).exactly(3).times.and_return("test")
        Post.should_receive(:fetch_from_api_response).with("test", {save: true}).exactly(3).times.and_return([1,2])
        Post.fetch(uids: [1,1,1], api: @api, save: true)
      end
    end
  end

  describe "#fetch_like_uids" do
    it "returns uids of users who liked this post", now: true do
      Post.api=double("api")
      Post.api.should_receive(:likes_getList).with({item_id: 5, owner_id: 6, type: "post"}).and_return({response:{count: 2, users:[3,4]}})
      post=Post.new(vk_id: 5, owner_id: 6)
      post.fetch_like_uids.should == [3,4]
    end
  end


  describe "#fetch_likes" do
    let!(:post) {Post.new vk_id: 1, owner_id: 2}

    before :each do
      @profiles=[]
      3.times { |i| @profiles << FactoryGirl.create(:user_profile, vk_id: i+1)}
      @profiles[1].status=1
      @profiles[1].save
    end

    it "fetches likes and saves them in db" do
      post.should_receive(:fetch_like_uids).and_return([1,2,3,4])
      post.should_receive(:save)
      UserProfile.should_receive(:new).twice
      post.fetch_likes
    end
    context "with_profiles: true" do
      it "fetches profiles that are not fetched yet", now: true do
        post.should_receive(:fetch_like_uids).and_return([1,2,3,4])
        post.should_receive(:save)
        UserProfile.should_receive(:fetch).with({uids: [2,4],save: true}).and_return([])
        post.fetch_likes with_profiles: true
        post.likes_user_profiles.to_a.map(&:vk_id).should==[1,3]
      end
    end
  end

  
end

