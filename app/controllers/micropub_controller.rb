class MicropubController < ApplicationController
  skip_forgery_protection

  FORM_ENCODED = "application/x-www-form-urlencoded"

  MICROFORMAT_OBJECT_TYPES = {
    entry: {
      class: Entry
    }
  }

  class InvalidMicroformat < StandardError; end

  def create
    if request.headers["Content-type"] == FORM_ENCODED

      microformat = MICROFORMAT_OBJECT_TYPES[params[:h].to_sym]

      raise InvalidMicroformat if !microformat

      microformat_object = microformat[:class].new

      if params[:content]
        microformat_object.content = params[:content]
      end

      if params[:category]
        microformat_object.categorizations_attributes = params[:category].map { |category|
          {
            category_attributes: {
              name: category
            }
          }
        }
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
