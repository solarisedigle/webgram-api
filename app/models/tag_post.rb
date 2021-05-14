class TagPost < ApplicationRecord
  belongs_to :post
  belongs_to :tag
  after_destroy :clean_up_unused_tags
  def clean_up_unused_tags
    tags_to_delete = Tag.where(id: self.tag.id)
    for tag in tags_to_delete do
      if TagPost.where(tag: tag).length == 0
        tag.destroy()
      end
    end
  end
end
