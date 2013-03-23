class Room < ActiveRecord::Base
  has_many :bookings ##tells RoR that the room will be attached to many different bookings

  attr_accessible :base_rate, :capacity, :description, :kitchen, :name, :stage
  ##these are all attributes available to the object, and will be saved with the record

  ## validations ##

  validates :base_rate, :capacity, :numericality => {:only_integer => true, :greater_than => 0} ##makes sure capacity and base_rate are both integers
  validates :kitchen, :stage, :inclusion => {:in => [true, false]} ## makes sure that kitchen & stage are both boolean
  validates :description, :length => {:within => 10...1024} ##makes sure the description isn't too long, or too short
  validates :name, :presence => true
  validates :name, :uniqueness => true

end