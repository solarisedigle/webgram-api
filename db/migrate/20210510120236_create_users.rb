class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, index: { unique: true }
      t.string :password
      t.text :description
      t.integer :activated, :limit => 8
      t.string :role
      t.integer :last_action

      t.timestamps
    end
    User.create(:username => 'admin', :password => '28125ee0a84ae4726602a3cb6dfbd3947cd4e438dd4cac2b7e4411d9fa8306cd', :role => 'admin', :activated => '1')
  end
end
