class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, index: { unique: true }
      t.string :password
      t.text :description
      t.integer :activated, :limit => 1
      t.string :role
      t.integer :last_action

      t.timestamps
    end
  end
end
