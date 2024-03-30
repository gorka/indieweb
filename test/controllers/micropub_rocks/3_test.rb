require "test_helper"

class MicropubRocks1Test < ActionDispatch::IntegrationTest
  test "300: Create an h-entry with a photo (multipart)" do
    data = {
      h: "entry",
      content: "Nice sunset tonight",
      photo: fixture_file_upload("sunset.jpg", "image/jpeg")
    }

    post micropub_path, params: data

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Nice sunset tonight"
    assert_select 'img[src$="sunset.jpg"]'
  end
end