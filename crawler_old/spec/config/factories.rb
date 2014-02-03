require "factory_girl"
FactoryGirl.define do
  factory :user_profile do
    sequence(:vk_id) {|n| n}
    
    factory :user_profile_with_friends do
      ignore do
        friends_count 3
      end

      after(:create) do |user_profile, evaluator|
        friends=FactoryGirl.create_list(:user_profile, evaluator.friends_count)
        user_profile.primary_friends=friends
      end
    end
  end

  factory :frontier do
    sequence(:vk_id) {|n| n}
    status 0
    factory :frontier_of_3 do
      after(:create) do |frontier, evaluator|
        FactoryGirl.create_list(:frontier, 2)
      end
      factory :frontier_of_3_first_busy do
        status 1
        updated_at Time.now
      end
      factory :frontier_of_3_first_busy_with_timeout do
        updated_at Time.now - 20_000_000
      end  
    end
  end

end
