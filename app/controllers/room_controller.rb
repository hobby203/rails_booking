class RoomController < ApplicationController
  before_filter :is_admin?, :except => :view ##makes sure that users can only view rooms, unless they are an admin
  
  def view ##function for showing the view for viewing rooms
    if Room.any?
      @rooms = Room.find(:all) ##finds all the rooms in the database and puts them into an array of objects
    else
      flash[:info] = "There are no rooms available at this time"
      redirect_to root_url
    end
  end

  def new ##function for showing the form to create a new room
    @newRoom = Room.new ##creates new blank room object for building the input form
    flash[:info] = "<strong>Important!</strong> Please make sure to upload your image to the correct location, and make sure it is named the same as the room, this is case sensitive.".html_safe
    ##the above line shows a message to the user, reminding them to put the image for the room in the correct place, otherwise it will not show
  end

  def process_new ##function for actually creating the new room
    @newRoom = Room.new(params[:room]) ##creates a new room object from the parameters sent from the view
    if @newRoom.save ##if there are no errors when RoR tries to save the new object
      flash[:message] = "Room created Succesfully" ##tells the user all is well
      redirect_to :action => "view" ##sends them back to the view all rooms page to admire their handiwork
    else
      render :action => "new" ##otherwise sends them back to try again
    end
  end

  def edit ##function for showing the form to edit a room
    begin
      @room_toEdit = Room.find(params[:id]) ##creates a new object for the room to be edited, so that the form will already be filled in for the user
    rescue ActiveRecord::RecordNotFound ##occurs if the specified ID doesn't have a room associated with it
      flash[:error] = "Room not found, did you type the ID in yourself?" ##tells the user it went wrong
      redirect_to :action => "view" ##sends them back to the view rooms
    end
  end

  def process_edit ##function for actually editing a room
    @room_toEdit = Room.find(params[:id]) ##finds the room by the ID passed
    if @room_toEdit.update_attributes(params[:room]) ##if the edits don't break anything
      flash[:message] = "Room updated succesfully" ##tells the user all is well
      redirect_to :action => "view" ##sends them back to the view all rooms to admire their handiwork
    else
      render :action => "edit", :id => params[:id] ##otherwise sends them back to try again
    end
  end

  def delete ##function for showing the delete button for a room
    begin
      @room_toDelete = Room.find(params[:id]) ##finds room by its ID, so the view knows which room's being deleted
    rescue ActiveRecord::RecordNotFound ##occurs when the ID cannot be found in the database
      flash[:error] = "Room not found, did you type the ID in yourself?" ##tells the user it went wrong
      redirect_to :action => "view" ##sends the user back to the view page
    end
  end

  def process_delete ##function for actually deleting a room
    @room_toDelete = Room.find(params[:id]) ##finds the room by the ID passed 
    if @room_toDelete.bookings.any? ##checks to see if the room has any bookings attached to it
      @room_toDelete.bookings.destroy_all ##deletes them all if it does
    end
    @room_toDelete.destroy ##deletes the room and removes it from the database
    flash[:message] = "Room removed succesfully" ##tells the user it all worked
    redirect_to :action => "view" ##sends them back to the view all rooms page
  end

end