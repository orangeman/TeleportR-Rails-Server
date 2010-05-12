require 'test_helper'

class GeonamesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:geonames)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create geoname" do
    assert_difference('Geoname.count') do
      post :create, :geoname => { }
    end

    assert_redirected_to geoname_path(assigns(:geoname))
  end

  test "should show geoname" do
    get :show, :id => geonames(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => geonames(:one).to_param
    assert_response :success
  end

  test "should update geoname" do
    put :update, :id => geonames(:one).to_param, :geoname => { }
    assert_redirected_to geoname_path(assigns(:geoname))
  end

  test "should destroy geoname" do
    assert_difference('Geoname.count', -1) do
      delete :destroy, :id => geonames(:one).to_param
    end

    assert_redirected_to geonames_path
  end
end
