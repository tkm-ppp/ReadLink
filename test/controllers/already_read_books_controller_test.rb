require "test_helper"

class AlreadyReadBooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get already_read_books_create_url
    assert_response :success
  end

  test "should get destroy" do
    get already_read_books_destroy_url
    assert_response :success
  end
end
