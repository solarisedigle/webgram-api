class User < ApplicationRecord
    validates :username, uniqueness: { case_sensitive: false }, format: { with: /\A^(?=.{5,30}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$\z/, message: "5-30 characters. Only [A-Z], [a-z] and delimiters [.] [_] are allowed" }
    validates :password, presence: true
end
