require "test_helper"

class WantToReadBooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get want_to_read_books_create_url
    assert_response :success
  end

  test "should get destroy" do
    get want_to_read_books_destroy_url
    assert_response :success
  end
end
