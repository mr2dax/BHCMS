require 'test_helper'

class ExportedPagesControllerTest < ActionController::TestCase
  setup do
    @exported_page = exported_pages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exported_pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exported_page" do
    assert_difference('ExportedPage.count') do
      post :create, exported_page: @exported_page.attributes
    end

    assert_redirected_to exported_page_path(assigns(:exported_page))
  end

  test "should show exported_page" do
    get :show, id: @exported_page
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @exported_page
    assert_response :success
  end

  test "should update exported_page" do
    put :update, id: @exported_page, exported_page: @exported_page.attributes
    assert_redirected_to exported_page_path(assigns(:exported_page))
  end

  test "should destroy exported_page" do
    assert_difference('ExportedPage.count', -1) do
      delete :destroy, id: @exported_page
    end

    assert_redirected_to exported_pages_path
  end
end
