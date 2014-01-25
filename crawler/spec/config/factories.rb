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
end
