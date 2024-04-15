require "test_helper"

class MicropubRocks1Test < ActionDispatch::IntegrationTest
  setup do
    # todo: mock to avoid http requests during tests.
    @headers = {
      "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtZSI6Imh0dHBzOlwvXC9maW5jaC1wb3B1bGFyLWltcGFsYS5uZ3Jvay1mcmVlLmFwcFwvIiwiaXNzdWVkX2J5IjoiaHR0cHM6XC9cL3Rva2Vucy5pbmRpZWF1dGguY29tXC90b2tlbiIsImNsaWVudF9pZCI6Imh0dHBzOlwvXC9taWNyb3B1Yi5yb2Nrc1wvIiwiaXNzdWVkX2F0IjoxNjkzODU3ODk3LCJzY29wZSI6ImNyZWF0ZSB1cGRhdGUgZGVsZXRlIHVuZGVsZXRlIiwibm9uY2UiOjg4Njc4OTY5fQ.BPoiJoCYxobqK8QJHc3MeolyStkEZl5pQIw2pD9isNg"
    }
  end

  test "100: Create an h-entry post (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating a basic h-entry"
    }

    post micropub_path, params: data, headers: @headers

    assert_response :created
  end

  test "101: Create an h-entry post with multiple categories (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating an h-entry with categories. This post should have two categories, test1 and test2",
      category: [ "test1", "test2" ]
    }

    post micropub_path, params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating an h-entry with categories. This post should have two categories, test1 and test2"
    assert_select ".p-category", count: 2
    assert_select ".p-category", text: "test1", count: 1
    assert_select ".p-category", text: "test2", count: 1
  end

  test "104: Create an h-entry with a photo referenced by URL (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating a photo referenced by URL",
      photo: "https://micropub.rocks/media/sunset.jpg"
    }

    post micropub_path, params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating a photo referenced by URL"
    assert_select 'img[src$="sunset.jpg"]'
  end

  test "107: Create an h-entry post with one category (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating an h-entry with one category. This post should have one category, test1",
      category: "test1"
    }

    post micropub_path, params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating an h-entry with one category. This post should have one category, test1"
    assert_select ".p-category", count: 1
    assert_select ".p-category", text: "test1", count: 1
  end
end
