require "open-uri"

class MicropubController < ApplicationController
  skip_forgery_protection

  before_action :authenticate, only: %i[ create ]

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

  PERMITTED_ACTIONS = %w[ create delete ]

  class InvalidAction < StandardError; end
  class InvalidMicroformat < StandardError; end

  def create
    if request.content_type =~ CONTENT_TYPES[:FORM_ENCODED] || request.content_type =~ CONTENT_TYPES[:MULTIPART]
      action = request.POST[:action]
      microformat = params[:h]

      if valid_action = PERMITTED_ACTIONS.include?(action)
        send("form_#{action}_action") and return
      end

      if !action && microformat
        form_create_action and return
      end

      raise InvalidMicroformat if !microformat
      raise InvalidAction
    end

    if request.content_type =~ CONTENT_TYPES[:JSON]
      action = params[:micropub][:action]
      microformat_sym = params[:type]&.first&.split("-")&.pop&.to_sym

      if valid_action = PERMITTED_ACTIONS.include?(action)
        send("json_#{action}_action") and return
      end

      if !action && microformat = MICROFORMAT_OBJECT_TYPES[microformat_sym]
        json_create_action(microformat) and return
      end

      raise InvalidMicroformat if !microformat
      raise InvalidAction
    end
  end

  private

    def authenticate
      # https://tokens.indieauth.com/#verify

      token = http_header_token || post_body_token

      render json: {
        "error": "unauthorized",
        "error_description": "You must provide an auth token"
      }, status: :unauthorized and return if !token

      # todo: Quill sends auth token both ways and I want to use Quill.
      # render json: {
      #   "error": "bad request",
      #   "error_description": "Provide only one auth token"
      # }, status: :bad_request and return if http_header_token && post_body_token

      data, error = IndieAuth::TokenVerifier.verify(token)

      render json: error[:body], status: error[:status] and return if error

      data

      # todo:
      # - verify that me is the same blog domain
      # - verify that issued_by is the same blog token_endpoint
      # - verify scope permission
      # - store? client_id for reference
    end

    def form_create_action
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

    def form_delete_action
      resource = resource_from_url(params[:url])

      if resource.update(deleted_at: Time.now)
        head :no_content
      else
        render json: {
          "error": "bad request",
          "error_description": "Something wen't wrong then deleting this resource."
        }, status: :bad_request
      end
    end

    def http_header_token
      authenticate_with_http_token { |token, _options| token }
    end

    def json_create_action(microformat)
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

    def json_delete_action
      resource = resource_from_url(params[:url])

      if resource.update(deleted_at: Time.now)
        head :no_content
      else
        render json: {
          "error": "bad request",
          "error_description": "Something wen't wrong then deleting this resource."
        }, status: :bad_request
      end
    end

    def post_body_token
      params[:access_token]
    end

    def resource_from_url(url)
      path = URI.parse(url)&.path
      return unless path

      route = Rails.application.routes.recognize_path(path)

      microformat_sym = route[:controller].singularize.to_sym
      return unless microformat_sym

      microformat = MICROFORMAT_OBJECT_TYPES[microformat_sym]
      return unless microformat

      microformat_class = microformat[:class]
      return unless microformat_class

      microformat_class.find_by(id: route[:id])
    end
end
