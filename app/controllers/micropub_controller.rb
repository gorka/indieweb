require "open-uri"

class MicropubController < ApplicationController
  skip_forgery_protection

  CONTENT_TYPES = {
    FORM_ENCODED: "application/x-www-form-urlencoded",
    JSON: "application/json"
  }

  MICROFORMAT_OBJECT_TYPES = {
    entry: {
      class: Entry
    }
  }

  class InvalidMicroformat < StandardError; end

  def create
    if request.headers["Content-type"] == CONTENT_TYPES[:FORM_ENCODED]
      microformat = MICROFORMAT_OBJECT_TYPES[params[:h].to_sym]

      raise InvalidMicroformat if !microformat

      microformat_object = microformat[:class].new

      if params[:content]
        microformat_object.content = params[:content]
      end

      if params[:category]
        categories = [params[:category]].flatten

        categorizations_attributes = categories.map { |category|
          {
            category_attributes: {
              name: category
            }
          }
        }

        microformat_object.categorizations_attributes = categorizations_attributes
      end

      if params[:photo]
        begin
          photo_uri = URI.parse(params[:photo])
          microformat_object.photos.attach(io: photo_uri.open, filename: File.basename(photo_uri.path))
        rescue => error
          puts "-" * 100
          p error
          puts "-" * 100
        end
      end

      if microformat_object.save
        response.headers["Location"] = entry_url(microformat_object)
        head :created
      else
        head :unprocessable_entity
      end
    end

    if request.headers["Content-type"] == CONTENT_TYPES[:JSON]
      microformat_param = params[:type]&.first&.split("-")&.pop
      microformat = MICROFORMAT_OBJECT_TYPES[microformat_param.to_sym]

      raise InvalidMicroformat if !microformat

      properties = params[:properties]

      microformat_object = microformat[:class].new

      if properties[:content].any?
        microformat_object.content = properties[:content].first
      end

      if properties[:category]&.any?
        categorizations_attributes = properties[:category].map { |category|
          {
            category_attributes: {
              name: category
            }
          }
        }

        microformat_object.categorizations_attributes = categorizations_attributes
      end

      if microformat_object.save
        response.headers["Location"] = entry_url(microformat_object)
        head :created
      else
        head :unprocessable_entity
      end
    end
  end
end
