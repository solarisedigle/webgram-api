class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  belongs_to :parent, optional: true
  has_many :replies, foreign_key: :parent_id, class_name: 'Comment', dependent: :destroy
  validates :body, presence: true, length: { maximum: 250 }
  def main_data
      return {
          id: self.id,
          created_at: self.created_at,
          parent_id: self.parent_id,
          body: self.body,
          replies: self.replies.size,
          user: self.user.main_data,
      }
  end
end
