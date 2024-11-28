require "test_helper"

class BookAuthorsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get book_authors_create_url
    assert_response :success
  end

  test "should get destroy" do
    get book_authors_destroy_url
    assert_response :success
  end
end
