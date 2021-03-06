class Subscription < ApplicationRecord
  belongs_to :user, counter_cache: :count_of_subscribers, foreign_key: 'user_id', class_name: 'User', required: true
  belongs_to :subscriber, foreign_key: 'subscriber_id', class_name: 'User', required: true
end
