class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.integer 'user_id', null: false
      t.integer 'subscriber_id', null: false

      t.timestamps
    end
  end
end
