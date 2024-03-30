require "open-uri"

class MicropubController < ApplicationController
  skip_forgery_protection

  CONTENT_TYPES = {
    FORM_ENCODED: /application\/x-www-form-urlencoded/,
    JSON: /application\/json/,
    MULTIPART: /multipart\/form-data/
  }

  MICROFORMAT_OBJECT_TYPES = {
    entry: {
      class: Entry
    }
  }

  class InvalidMicroformat < StandardError; end

  def create
    if request.content_type =~ CONTENT_TYPES[:FORM_ENCODED] || request.content_type =~ CONTENT_TYPES[:MULTIPART]
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
        photos = [params[:photo]].flatten

        microformat_photos_attributes = photos.reduce([]) do |acc, curr|
          if request.content_type =~ CONTENT_TYPES[:FORM_ENCODED]
            begin
              photo_uri = URI.parse(curr)
            rescue => error
              puts "-" * 100
              p error
              puts "-" * 100
            end
  
            photo_data = photo_uri.open
            photo_name = File.basename(photo_uri.path)
          end
  
          if request.content_type =~ CONTENT_TYPES[:MULTIPART]
            photo_data = curr
            photo_name = curr.original_filename
          end

          acc << {
            photo_with_alt_attributes: {
              alt: "",
              photo_data:,
              photo_name:
            }
          }

          acc
        end

        microformat_object.microformat_photos_attributes = microformat_photos_attributes
      end

      if microformat_object.save
        response.headers["Location"] = entry_url(microformat_object)
        head :created
      else
        head :unprocessable_entity
      end
    end

    if request.content_type =~ CONTENT_TYPES[:JSON]
      microformat_param = params[:type]&.first&.split("-")&.pop
      microformat = MICROFORMAT_OBJECT_TYPES[microformat_param.to_sym]

      raise InvalidMicroformat if !microformat

      properties = params[:properties]

      microformat_object = microformat[:class].new

      if properties[:content].any?
        content = properties[:content].first

        kontent = case content
        when String
          content
        when ActionController::Parameters
          content[:html]
        else
          ""
        end

        microformat_object.content = kontent
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

      if properties[:photo]&.any?
        microformat_photos_attributes = properties[:photo].reduce([]) do |acc, curr|
          begin
            photo_uri, alt = case curr
            when String
              [URI.parse(curr), ""]
            when ActionController::Parameters
              [URI.parse(curr["value"]), curr[:alt]]
            end
          rescue => error
            puts "-" * 100
            p error
            puts "-" * 100
          end

          acc << {
            photo_with_alt_attributes: {
              alt: alt,
              photo_data: photo_uri.open,
              photo_name: File.basename(photo_uri.path)
            }
          }

          acc
        end

        microformat_object.microformat_photos_attributes = microformat_photos_attributes
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
