class Like < ApplicationRecord
  belongs_to :user, required: true, counter_cache: :count_of_likes
  belongs_to :post, required: true, counter_cache: :count_of_likes
end
