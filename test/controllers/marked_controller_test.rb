require "test_helper"

class MarkedControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get marked_index_url
    assert_response :success
  end
end
