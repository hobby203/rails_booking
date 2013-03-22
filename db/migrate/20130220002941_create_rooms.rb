class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.text :description
      t.integer :capacity
      t.integer :base_rate
      t.boolean :stage
      t.boolean :kitchen

      t.timestamps
    end
  end
end
