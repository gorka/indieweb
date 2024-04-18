class MediaController < ApplicationController
  include IndieAuth

  skip_forgery_protection

  ALLOWED_CONTENT_TYPES = [
    "image/gif",
    "image/jpeg",
    "image/png"
  ]

  def create
    unless request.content_type =~ MicropubController::CONTENT_TYPES[:MULTIPART]
      render json: {
        "error": "bad request",
        "error_description": "Invalid request."
      }, status: :bad_request and return
    end

    file = params[:file]

    puts "-" * 100
    p file.content_type
    puts "-" * 100

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      render json: {
        "error": "unprocessable entity",
        "error_description": "Invalid content type."
      }, status: :unprocessable_entity and return
    end

    photo_with_alt = PhotoWithAlt.new(alt: "")
    photo_with_alt.photo.attach(io: file, filename: file.original_filename)

    if photo_with_alt.save
      response.headers["Location"] = url_for(photo_with_alt.photo)
      head :created
    else
      render json: {
        "error": "unprocessable entity",
        "error_description": "Invalid file format."
      }, status: :unprocessable_entity
    end
  end
end
