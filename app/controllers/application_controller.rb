class ApplicationController < ActionController::Base
  protect_from_forgery ##prevents against CSRF attacks, default on all RoR apps
  before_filter :current_user ##before the controller can run any subroutine, it must make sure that this function returns true

  def current_user ##function to set the current user
    if session[:id] ##this will be true if a user has logged in
      @current_user ||= User.find(session[:id]) ##if the "current_user" object is empty, it will create one for the logged in user, otherwise it will leave it
    end
  end

  def logged_in? ##function to check if a user is logged in
    unless session[:id] ##if there is no session[:id], a user will not have logged in
      flash[:error] = "You need to be logged in for that" ##tells the user that they are not logged in
      redirect_to :controller => "user", :action => "login" ##redirects user to the login page
    else 
      return true ##the function will return true if the session[:id] exists, and a user is therefore logged in
    end 
  end

  def is_admin? ##function to see if a user is an administrator
    unless session[:id] && @current_user.admin ##checks if there is a user logged in, and that they are an admin
      flash[:error] = "You need to be an administrator for that" ##tells a user they are not an admin
      redirect_to root_url ##redirects them back to the homepage
    else
      return true ##the function will return true if there is a user logged in, and they are an admin
    end
  end
end