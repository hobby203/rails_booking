require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get process_login" do
    get :process_login
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get process_edit" do
    get :process_edit
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get process_new" do
    get :process_new
    assert_response :success
  end

end
