class MediaController < ApplicationController
  include IndieAuth

  skip_forgery_protection

  def create
    response.headers["Location"] = "file_url"
    head :created
  end
end
