class Post < ApplicationRecord
    validates :title, presence: true, length: { maximum: 200 }
    validates :body, presence: true, length: { maximum: 3000 }
    validates :image, format: URI::regexp(%w[http https]), allow_blank: true
    belongs_to :user, required: true
    belongs_to :category, required: true
    has_many :likes, dependent: :destroy
    has_many :comments, dependent: :destroy
end
