class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :body
      t.integer 'post_id', null: false
      t.integer 'user_id', null: false
      t.integer 'parent_id', null: true
      t.timestamps
    end
  end
end
