class User < ActiveRecord::Base
  has_many :bookings ##tells RoR that the user will have many bookings attached to it

  attr_accessible :admin, :email, :forename, :local, :over_18, :password_hash, :password_salt, :surname, :title, :username, :password_confirmation, :email_confirmation, :password
  ##these are all attributes available to the object, however it will only save to the database those which have a corresponding field
  attr_accessor :password
  ##tells RoR not to look for this field in the database, as it will not be saved. This is automatic for those attributes with :confirmation => true
  before_save :encrypt_password
  ##tells RoR to run the "encrypt_password" function before saving the object to the database

  ## validations ##

  validates :forename, :surname, :username, :email, :password, :presence => true
  validates :email, :password, :confirmation => true ##creates virtual attributes for confirming email & password
  validates :admin, :local, :over_18, :inclusion => {:in => [true, false]} ##makes sure these fields are boolean
  validates :title, :inclusion => {:in => %w(Dr Mrs Mr Miss Ms Mx)} ##makes sure title is correct
  validates :forename, :length => {:maximum => 250} ##makes sure their first name isn't too long, as set out by deed poll
  validates :surname, :length => {:maximum => 30} ##makes sure their surname isn't too long, as set out by deed poll
  validates :password, :length => {:minimum => 8} ##makes sure the password is at least 8 characters
  validates :email, :username, :length => {:maximum => 255} ##makes sure all other fields aren't too long
  validates :username, :email, :uniqueness => true ##makes sure that the username or email is unique, to avoid login problems

  ## functions ##

  def encrypt_password ##function for encrypting the password for storage in the database
    self.password_salt = BCrypt::Engine.generate_salt ##generates a salt for hashing the password
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt) ##hashes the password using the salt
  end

  def self.authenticate(username, password) ##function for authenticating a user with their password
    user = find_by_username(username) ##finds the correct user by the username given
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt) ##if the user was found, and the stored password hash matches the hash of the given password
      return user ##returns the user object
    else
      return nil ##otherwise returns "nothing"
    end
  end

  def fullname ##function for creating a user's full name from its 3 constituents
    return self.title + " " + self.forename + " " + self.surname ##returns the full name, i.e. the title, followed by the forname, followed by the surname
  end
end
