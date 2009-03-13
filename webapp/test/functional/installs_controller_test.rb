require 'test_helper'

class InstallsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:installs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create install" do
    assert_difference('Install.count') do
      post :create, :install => { }
    end

    assert_redirected_to install_path(assigns(:install))
  end

  test "should show install" do
    get :show, :id => installs(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => installs(:one).id
    assert_response :success
  end

  test "should update install" do
    put :update, :id => installs(:one).id, :install => { }
    assert_redirected_to install_path(assigns(:install))
  end

  test "should destroy install" do
    assert_difference('Install.count', -1) do
      delete :destroy, :id => installs(:one).id
    end

    assert_redirected_to installs_path
  end
end
