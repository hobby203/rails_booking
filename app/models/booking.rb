class Booking < ActiveRecord::Base
  belongs_to :user ##tells RoR that the Booking will have one user attached to it
  belongs_to :room ##tells RoR that the Booking will have one room attached to it

  attr_accessible :bar, :event_type, :finish, :room_id, :start, :user_id, :details, :attendees, :total_price
  ##this is a list of all attributes available to the object, and those which will be saved with the record

  ## validations ##

  validates :bar, :inclusion => {:in => [true, false]} ## makes sure that bar is boolean
  validates :event_type, :start, :finish, :presence => true ##makes sure that these fields are present
  validates :room_id, :user_id, :attendees, :numericality => {:only_integer => true, :greater_than => 0} ## makes sure that room_id and user_id are both integers
  validates :total_price, :numericality => {:greater_than => 0} ## makes sure that total_price is greater than 0

end
