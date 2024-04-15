require "test_helper"

class MicropubRocks3Test < ActionDispatch::IntegrationTest
  setup do
    # todo: mock to avoid http requests during tests.
    @headers = {
      "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtZSI6Imh0dHBzOlwvXC9maW5jaC1wb3B1bGFyLWltcGFsYS5uZ3Jvay1mcmVlLmFwcFwvIiwiaXNzdWVkX2J5IjoiaHR0cHM6XC9cL3Rva2Vucy5pbmRpZWF1dGguY29tXC90b2tlbiIsImNsaWVudF9pZCI6Imh0dHBzOlwvXC9taWNyb3B1Yi5yb2Nrc1wvIiwiaXNzdWVkX2F0IjoxNjkzODU3ODk3LCJzY29wZSI6ImNyZWF0ZSB1cGRhdGUgZGVsZXRlIHVuZGVsZXRlIiwibm9uY2UiOjg4Njc4OTY5fQ.BPoiJoCYxobqK8QJHc3MeolyStkEZl5pQIw2pD9isNg"
    }
  end

  test "300: Create an h-entry with a photo (multipart)" do
    data = {
      h: "entry",
      content: "Nice sunset tonight",
      photo: fixture_file_upload("sunset.jpg", "image/jpeg")
    }

    post micropub_path, params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Nice sunset tonight"
    assert_select 'img[src$="sunset.jpg"]'
  end

  test "301: Create an h-entry with two photos (multipart)" do
    data = {
      h: "entry",
      content: "This post should have two photos",
      photo: [
        fixture_file_upload("sunset.jpg", "image/jpeg"),
        fixture_file_upload("city-at-night.jpg", "image/jpeg")
      ]
    }

    post micropub_path, params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "This post should have two photos"
    assert_select 'img[src$="sunset.jpg"]'
    assert_select 'img[src$="city-at-night.jpg"]'
  end
end
