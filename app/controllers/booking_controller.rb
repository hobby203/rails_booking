class BookingController < ApplicationController

  before_filter :logged_in? ##makes sure the user is logged in before they can see any bookings

  def view ##function for viewing all bookings
    if Booking.any?
      if params[:view] == "own" && @current_user.bookings.any? ##checks if the user wants to see just their own bookings, and they have bookings made
        @bookings = @current_user.bookings ##finds all the bookings belonging to the user logged in
        @title = "Viewing Your Bookings" ##creates the title for the page
        @own = true ##tells the page that the user wants to only see their own bookings, so it can create a link to see all bookings
      else ##otherwise
        @bookings = Booking.find(:all) ##selects all bookings in the database
        @title = "Viewing All Bookings" ##creates the title for the page
        @own = false ##tells the page that the user isn't viewing just their own bookings, so it can create a link to see just their own
      end
    else
      flash[:info] = "There are no bookings at this time"
      redirect_to request.referer
    end
  end

  def new ##function for showing the page to create a new booking
    @newBooking = Booking.new ##creates temporary Object for a booking, so as to create the form in the view
  end

  def process_new ##function for actually creating the new booking
    @newBooking = @current_user.bookings.new(params[:booking]) ##takes the information for the booking from the view, and adds it to the object "newBooking"
    if @current_user.local ##checks if the user is a local
      @newBooking.total_price = ((Room.find(@newBooking.room_id).base_rate/100.0)*80).to_i ##if they are, it sets the price of the booking to 80% of the full rate
    else
      @newBooking.total_price = Room.find(@newBooking.room_id).base_rate.to_i ##otherwise sets price to the room's full rate
    end
    @newBooking.total_price = ((@newBooking.finish - @newBooking.start).to_f/3600)*@newBooking.total_price ##converts the length of the booking to hours, and then multiplies it by the hourly rate to get the final price
    if @newBooking.bar ##checks if the user wanted the Bar facilities
      @newBooking.total_price = (@newBooking.total_price + 50).to_i ##if they did, adds the cost of the bar onto the booking price
    end
    if Booking.find_by_room_id(@newBooking.room_id) ##checks if there are any other bookings for that room
      @bookings = Booking.find_by_room_id(@newBooking.room_id) ##if there are, creates an array of objects containing each booking
      begin
        @bookings.each do |oldBooking| ##iterates through each booking, each time using the word "oldBooking" to represent the booking it is currently checking
          check_taken(@newBooking, oldBooking) ##runs the check_taken function to see if the bookings will overlap
        end
      rescue NoMethodError ##this will be returned if there is only one booking for the room, due to an issue with the .each method
        check_taken(@newBooking, @bookings) ##just checks the single booking against the current for overlap.
      end
    end
    if @taken ##this will be true if any of the current bookings will overlap with the new one
      flash[:error] = "The chosen time has already been taken" ##tell the user as such
      render :action => "new" ##send them back to the form to change the time
    elsif !@current_user.over_18 && @newBooking.bar ##checks to make sure a minor cannot use the bar services, for legal reasons
      flash[:error] = "Under 18s may not use the bar facilities" ##tells the user they cannot have a bar if they are underage
      render :action => "new" ##returns them to the form to try again

    elsif @newBooking.start.past? || @newBooking.finish.past? ##makes sure they haven't accidentally set the booking to start/finish in the past
      flash[:error] = "You can't create a booking for past dates" ##tells the user they're doing it wrong
      render :action => "new" ##sends them back to the form to try again

    elsif @newBooking.finish < @newBooking.start ##makes sure that the booking doesn't finish before it starts
      flash[:error] = "Your finish date can't be before the booking starts" ##tells the user they're doing it wrong
      render :action => "new" ##sends them back to try again
    elsif @newBooking.save ##tries to save the new booking
      MailUser.confirm_booking(@newBooking.id).deliver ##sends an email to the user with the booking details, along with further instruction
      flash[:message] = "New booking created successfully" ##tells the user the booking was created successfully
      redirect_to :action => "view", :view => "own" ##redirects them back to the view page

    else
      render :action => "new" ##otherwise, sends them back to the form, where they will be shown the errors with the booking
    end
  end

  def edit ##function for creating the page to edit a booking
    begin
      @booking_toEdit = Booking.find(params[:id]) ##finds the booking that needs editing, and creates an object to store it, so that the forms will already be filled in
    rescue ActiveRecord::RecordNotFound ##happens if the ID can't be found in the database
      flash[:error] = "Booking not found with that ID, did you type it in yourself?" ##tells the user it didn't work
      redirect_to :action => "view" ##sends them back to the view bookings screen
    end
  end

  def process_edit #function for actually editing the booking
    @booking_toEdit = Booking.find(params[:id]) ##finds the booking from the database
    if @booking_toEdit.update_attributes(params[:booking]) ##makes sure that the edits won't return any errors
      MailUser.confirm_booking(@booking_toEdit.id).deliver ##emails the user with the new details
      flash[:message] = "Edit was successful" ##tells the user their edits didn't break anything
      redirect_to :action => "view", :view => "own" ##redirects them back to viewing their own bookings
    else
      render :action => "edit" ##otherwise sends them back to try again
    end
  end

  def delete ##function for creating the page to delete a booking
    begin
      @booking_toDelete = Booking.find(params[:id]) ##finds the booking that needs deleting, and creates an object to store it so the view can tell the user what they're deleting
    rescue ActiveRecord::RecordNotFound ##happens if the booking cannot be found in the database
      flash[:error] = "Booking not found with that ID, did you type it in yourself?" ##tells the user it didn't work
      redirect_to :action => "view" ##sends them back to the view screen
    end  
  end

  def process_delete ##function for actually deleting a booking
    @booking_toDelete = Booking.find(params[:id]) ##finds the booking to delete from the database
    @booking_toDelete.destroy ##destroys the booking
    flash[:message] = "Booking removed successfully" ##tells the user the booking was deleted fine
    redirect_to :action => "view" ##redirects them back to viewing their own bookings
  end

  def check_taken(currentBooking, existingBooking) ##function for checking if 2 bookings will overlap
    @currentBooking = currentBooking ##sets the current booking as the one passed to the function
    @existingBooking = existingBooking ##sets the new booking as the one passed to the function
    if @currentBooking.start == @existingBooking.start ##if they start at the same time
      @taken = true ##tells the program the booking can't happen
    elsif @currentBooking.finish == @existingBooking.finish ##if they finish at the same time
      @taken = true ##tells the program the booking can't happen
    elsif @currentBooking.finish > @existingBooking.start && @currentBooking.start < @existingBooking.start ##if the new booking starts in the middle of the current one
      @taken = true ##tells the program the booking can't happen
    elsif @currentBooking.start < @existingBooking.finish && @currentBooking.finish > @existingBooking.start ##if the new booking finishes in the middle of the current one
      @taken = true ##tells the program the booking can't happen
    end
  end

end