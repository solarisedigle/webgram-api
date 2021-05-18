class Tag < ApplicationRecord
    validates :name, uniqueness: { case_sensitive: false }, format: { with: /\A^(?=.{2,50}$)(?![-])(?!.*[\-]{2})[a-zA-Z0-9\-]+(?<![\-])$\z/, message: "4-50 characters. Only [A-Z], [a-z], [0-9] and delimiter [-] are allowed" }
    has_many :tag_posts, dependent: :destroy, class_name: 'TagPost'
    has_many :posts, through: :tag_posts
end