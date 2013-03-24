class UserController < ApplicationController
  before_filter :logged_in?, :except => [:login, :process_login, :new, :process_new, :reset, :process_reset] ##makes sure the user is logged in, unless they are logging in, registering, or resetting their password
  before_filter :is_admin?, :only => [:view] ##makes sure only admins can view all registered users

  def login ##function to show page for logging in to system
    flash[:info] = "<strong>Warning!</strong> If you have not already registered, you will need to do so before you can continue".html_safe
    ##tells the user that they will need to register if they have not already
  end

  def process_login ##function for actually logging a user in
    user = User.authenticate(params[:user][:username],params[:user][:password]) ##tries to authenticate the user with the given name and password
    if user ##if authentication succeeded
      session[:id] = user.id ##sets the session[:id] to the user's ID, used for finding them again later
      flash[:message] = "Logged in Successfully" ##tell the user all went well
      redirect_to root_url ##sends them back to the home page
    else
      flash[:error] = "Login Unsuccesful" ##otherwise tell them they went wrong
      render "login" ## sends them back to the login page to try again
    end
  end

  def process_logout ##function for logging out a user
    session[:id] = nil ##resets the session[:id]
    @current_user = nil ##deletes the current_user object
    flash[:message] = "Logged Out Successfully" ##tells the user they've been logged out
    redirect_to root_url ##sends them to the home page
  end

  def edit ##function for showing the form to edit a user
    if params[:id] && @current_user.admin ##checks to see if the current user is an admin, and a user ID was supplied
      begin
        @user_toEdit = User.find(params[:id]) ##finds the user to edit by the ID supplied
      rescue ActiveRecord::RecordNotFound ##happens if the id doesn't exist
        flash[:error] = "User by that ID not found, did you input it yourself?" ##tells the user they went wrong
        redirect_to :action => "view" ##banishes user to from whence they came
      end
    else
      @user_toEdit = @current_user ##otherwise sets the user to edit as the current user
    end
  end

  def process_edit ##function for actually editing a user
    @user_toEdit = User.find(params[:id]) ##finds the user to edit by the ID supplied
    if @user_toEdit.update_attributes(params[:user]) ##checks if the edits will break anything
      flash[:message] = "Edit was successful" ##tells the user all went well
      if @current_user.admin ##if the user is an admin
        redirect_to :action => "view" ##sends them back to the view users screen, as it is likely this is where they came from
      else
        redirect_to :action => "account" ##otherwise sends them back to the account screen
      end
    else
      render :action => "edit" ##otherwise sends them back to try again
    end
  end

  def new ##function for showing the page to create a new user
    @newUser = User.new ##creates a new blank user object for building the form
    flash[:info] = "<strong>Important!</strong> Please make sure to include a correct email address, as this is how we will notify you of your bookings".html_safe
    ##the above message is to make sure tha users input a correct email, as this is important for confirming bookings and password resets
  end

  def process_new ##function for actually creating a new user
    @newUser = User.new(params[:user]) ##creates a new user object with the details provided in the previous form
    unless params[:user][:admin] ##checks if the user was selected to be an administrator
      @newUser.admin = false ##sets the admin field to false if they were not
    end
    if @newUser.save ##if the new object doesn't break anything
      MailUser.welcome(@newUser).deliver ##sends a confirmation email to the new user
      if @current_user ##if there was already a user logged in (and therefore an admin)
        flash[:message] = "New user created successfully" ##tells the user all is well
        redirect_to :action => "view" ##sends them back to the view all page
      else
        flash[:message] = "Your account has been created, and you have been logged in" ##otherwise tells the user they've been logged in
        session[:id] = @newUser.id ##sets the session id to the new user's id
        redirect_to root_url ##sends them back to the home page
      end
    else
      render :action => "new" ##otherwise sends them back to try again
    end
  end

  def account ##function for showing the account page, requires no logic
  end

  def view ##function for viewing all users (admin only)
    ##no clause required here for if there are no users, as there will have to be at least one to see this (the user logged in)
    @allUsers = User.find(:all) ##creates an array containing all users in the database
  end

  def delete ##function for showing page to delete user
    if params[:id] && @current_user.admin ##checks to see if an ID has been supplied, and the user is an admin
      begin
        @user_toDelete = User.find(params[:id]) ##finds the user to delete by their ID as supplied
        @title = "Removing User Account" ##title to show that the user is deleting another account
      rescue ActiveRecord::RecordNotFound ##happens when the ID given is not found in the database
        flash[:error] = "User not found by that ID, did you input it yourself?" ##tells them they went wrong
        redirect_to :action => "view" ##sends them back to where they came from
      end
    else
      @user_toDelete = @current_user ##otherwise sets the user to delete to be the current logged in user
      @title = "Removing your Account" ##title to reflect this
    end
  end

  def process_delete ##function for actually deleting a user
    @user_toDelete = User.find(params[:id]) ##finds the user to be deleted by their ID
    if @user_toDelete.bookings.any? ##checks to see if the user has any bookings
      @user_toDelete.bookings.destroy_all ##if it did, all bookings are destroyed
    end
    flash[:info] = "Account removed successfully" ##tells the user the account has been deleted
    @user_toDelete.destroy
    if @user_toDelete == @current_user ##checks to see if the deleted user is the currently logged in user
      process_logout ##logs them out if they were, so as to avoid error
    else
      redirect_to :action => "view" ##otherwise sends them back to the view all page, as they must have been an admin
    end
  end

  def password ##function for creating the page to change a password, no logic required
  end

  def process_password ##function for actually changing a password
    if BCrypt::Engine.hash_secret(params[:oldPass], @current_user.password_salt) != @current_user.password_hash ##makes sure the old password, when encrypted, matches the one input
      flash[:error] = "Your current password was incorrect" ##tells the user their password was wrong
      render :action => "password" ##sends them back to try again
    elsif params[:newPass] != params[:newPassCheck] ##makes sure they input the same password twice
      flash[:error] = "Your new passwords didn't match" ##tells them they can't type
      render :action => "password" ##sends them back to try again
    else
      @current_user.password = params[:newPass] ##sets the user's password to the new password
      @current_user.save ##saves the edited passsword
      flash[:message] = "Password changed successfully" ##tells them the password was changed successfully
      redirect_to :action => "account" ##sends them back to the account screen
    end
  end

  def reset ##function for showing password reset page, no logic required
  end

  def process_reset ##function for actually resetting a password
    if User.find_by_username(params[:user][:username]) ##if the input username corresponds to an actual user
      @user = User.find_by_username(params[:user][:username]) ##finds the user that correspongs to the username input
      @newPass = SecureRandom.hex(8) ##creates a random 8-digit string 
      @user.password = @newPass ##sets that string to the users's password
      @user.save ##saves the new password
      MailUser.pass_reset(@user.id, @newPass).deliver ##sends the user an email with their new password
      flash[:message] = "Password reset successfully, please check your emails for your new password" ##tells the user so
      redirect_to :action => "login" ##sends them back to the login screen
    else
      flash[:error] = "An account with that username was not found" ##tells the user the input username was wrong
      render :action => "reset" ##sends them back to try again
    end
  end
end