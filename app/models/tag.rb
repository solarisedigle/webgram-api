class Tag < ApplicationRecord
    validates :name, uniqueness: { case_sensitive: false }, format: { with: /\A^(?=.{4,50}$)(?![-])(?!.*[\-]{2})[a-zA-Z0-9\-]+(?<![\-])$\z/, message: "4-50 characters. Only [A-Z], [a-z], [0-9] and delimiter [-] are allowed" }
    has_many :posts_tags, dependent: :destroy, class_name: 'TagPost'
    has_many :posts, through: :posts_tags
end