class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :email
      t.string :title
      t.string :forename
      t.string :surname
      t.boolean :local
      t.boolean :over_18
      t.boolean :admin

      t.timestamps
    end
  end
end
