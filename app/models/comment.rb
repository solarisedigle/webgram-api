class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  belongs_to :parent, optional: true
  has_many :replies, foreign_key: :parent_id, class_name: 'Comment', dependent: :destroy
  validates :body, presence: true, length: { maximum: 1000 }
end
