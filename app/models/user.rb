class User < ApplicationRecord
    validates :username, uniqueness: { case_sensitive: false }, format: { with: /\A^(?=.{4,30}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$\z/, message: "5-30 characters. Only [A-Z], [a-z] and delimiters [.] [_] are allowed" }
    validates :description, length: { maximum: 200 }
    validates :password, presence: true
    
    has_many :posts, dependent: :destroy
    has_many :likes, dependent: :destroy

    has_many :subscriptions, dependent: :destroy
    has_many :subscriber_rel, foreign_key: :user_id, class_name: 'Subscription'
    has_many :subscribers, through: :subscriber_rel, source: :subscriber
    has_many :subscriber_rel, foreign_key: :subscriber_id, class_name: 'Subscription', dependent: :destroy
    has_many :users, through: :subscriber_rel, source: :user
end
