class MailUser < ActionMailer::Base
  default :from => "townhall@ehobbs.it" ##sets the default from address, all queries from users will be sent here via replies

  def welcome(user) ##function for sending welcome emails
    @user = user ##sets the user to be the user passed through
    mail(:to => @user.email, :subject => "Thank you for registering") ##creates the email from the template, with the subject, and sends it to the user
  end

  def pass_reset(userID, newPass) ##function for sending password reset emails
    @user = User.find(userID) ##finds the user to reset from the passed ID
    @password = newPass ##gives the password its own variable for easy access
    mail(:to => @user.email, :subject => "Password reset confirmation") ##creates the email from the template, with the subject, and sends it to the user
  end

  def confirm_booking(bookingID) ##function for confirming bookings via email
    @booking = Booking.find(bookingID) ##finds the booking from the ID passed
    @user = User.find(@booking.user_id) ##finds the booking owner from the booking
    mail(:to => @user.email, :subject => "Booking Confirmation") ##creates email from the template, with the subject, and sends it to the user
  end
end
