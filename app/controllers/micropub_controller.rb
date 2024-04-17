require "open-uri"

class MicropubController < ApplicationController
  include IndieAuth

  skip_forgery_protection

  before_action :set_blog, only: %i[ create ]

  CONTENT_TYPES = {
    FORM_ENCODED: /application\/x-www-form-urlencoded/,
    JSON: /application\/json/,
    MULTIPART: /multipart\/form-data/
  }

  MICROFORMAT_OBJECT_TYPES = {
    entry: {
      class: Entry,
      supported_properties: [
        "content",
        "category",
        "photo"
      ]
    }
  }.with_indifferent_access

  PERMITTED_ACTIONS = %w[ delete undelete ]

  class InvalidAction < StandardError; end
  class InvalidMicroformat < StandardError; end

  def show
    case params[:q]
    when "config"
      render json: {}, status: :ok
    when "syndicate-to"
      render json: { "syndicate-to": [] }, status: :ok
    when "source"
      resource = resource_from_url(params[:url])
      render json: format_resource_for_source(resource, params[:properties]), status: :ok
    else
      head :bad_request
      return
    end

  end

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

    def format_resource_for_source(resource, properties = [])
      microformat = MICROFORMAT_OBJECT_TYPES[resource.class.name.downcase]

      # todo: error if microformat doesn't exist. maybe one level up.

      supported_properties = microformat[:supported_properties]
      properties_to_return = properties.to_a.any? ? properties & supported_properties : supported_properties

      properties = {}

      if properties_to_return.include?("content")
        properties[:content] = [resource.content]
      end

      if properties_to_return.include?("category") && resource.categories.any?
        properties[:category] = resource.categories.map(&:name)
      end

      if properties_to_return.include?("photo") && resource.photos_with_alt.any?
        properties[:photo] = resource.photos_with_alt.map { |photo|
          if photo.alt?
            {
              value: url_for(photo.photo),
              alt: photo.alt
            }
          else
            url_for(photo.photo)
          end
        }
      end

      {
        type: ["h-entry"],
        properties: properties
      }
    end

    def form_create_action
      microformat = MICROFORMAT_OBJECT_TYPES[params[:h].to_sym]

      raise InvalidMicroformat if !microformat

      microformat_object = microformat[:class].new
      microformat_object.blog = @blog

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
          "error_description": "Something went wrong when deleting this resource."
        }, status: :bad_request
      end
    end

    def form_undelete_action
      resource = resource_from_url(params[:url])

      if resource.update(deleted_at: nil)
        head :no_content
      else
        render json: {
          "error": "bad request",
          "error_description": "Something went wrong when undeleting this resource."
        }, status: :bad_request
      end
    end

    def json_create_action(microformat)
      properties = params[:properties]

      microformat_object = microformat[:class].new
      microformat_object.blog = @blog

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
          "error_description": "Something went wrong when deleting this resource."
        }, status: :bad_request
      end
    end

    def json_undelete_action
      resource = resource_from_url(params[:url])

      if resource.update(deleted_at: nil)
        head :no_content
      else
        render json: {
          "error": "bad request",
          "error_description": "Something went wrong when undeleting this resource."
        }, status: :bad_request
      end
    end

    def resource_from_url(url)
      path = URI.parse(url)&.path
      return unless path

      controller_name, resource_id = path.split("/").reject(&:empty?)

      microformat = MICROFORMAT_OBJECT_TYPES[controller_name.singularize.to_sym]
      return unless microformat

      microformat_class = microformat[:class]
      return unless microformat_class

      microformat_class.unscoped.find_by(id: resource_id)
    end

    def set_blog
      @blog = Blog.find_by(subdomain: request.subdomain)

      if !@blog
        render json: {
          error: "invalid_request",
          error_description: "Invalid blog subdomain"
        }, status: :bad_request
      end
    end
end
