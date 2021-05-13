class Category < ApplicationRecord
    validates :name, presence: true, length: { maximum: 200 }
    validates :description, presence: true, length: { maximum: 1000 }
    has_many :posts, dependent: :destroy
end
