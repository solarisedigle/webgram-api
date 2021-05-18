class Post < ApplicationRecord
    validates :title, presence: true, length: { maximum: 200 }
    validates :body, presence: true, length: { maximum: 3000 }
    validates :image, format: URI::regexp(%w[http https]), allow_blank: true
    belongs_to :user, required: true
    belongs_to :category, required: true
    has_many :likes, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :tag_posts, dependent: :destroy, class_name: 'TagPost'
    has_many :tags, through: :tag_posts
    after_destroy :clean_data
    def clean_data
        if !self.image.nil?
            public_id = self.image.split('/')[-1].split('.')[0]
            Cloudinary::Uploader.destroy(public_id, options = {})
        end
    end
end
