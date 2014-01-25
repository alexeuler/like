class Like < ActiveRecord::Base
  belongs_to :user_profile
  belongs_to :post
end
