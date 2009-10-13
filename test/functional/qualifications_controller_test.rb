require 'test_helper'

class QualificationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:qualifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create qualification" do
    assert_difference('Qualification.count') do
      post :create, :qualification => { }
    end

    assert_redirected_to qualification_path(assigns(:qualification))
  end

  test "should show qualification" do
    get :show, :id => qualifications(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => qualifications(:one).to_param
    assert_response :success
  end

  test "should update qualification" do
    put :update, :id => qualifications(:one).to_param, :qualification => { }
    assert_redirected_to qualification_path(assigns(:qualification))
  end

  test "should destroy qualification" do
    assert_difference('Qualification.count', -1) do
      delete :destroy, :id => qualifications(:one).to_param
    end

    assert_redirected_to qualifications_path
  end
end
