class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :room_id
      t.integer :user_id
      t.datetime :start
      t.datetime :finish
      t.boolean :bar
      t.string :event_type

      t.timestamps
    end
  end
end
