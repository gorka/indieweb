require "open-uri"

class MicropubController < ApplicationController
  include IndieAuth
  include SetBlog

  skip_forgery_protection

  before_action :ensure_blog

  CONTENT_TYPES = {
    FORM_ENCODED: /application\/x-www-form-urlencoded/,
    JSON: /application\/json/,
    MULTIPART: /multipart\/form-data/
  }

  PERMITTED_ACTIONS = %w[ delete undelete update ]
  PERMITTED_UPDATE_ACTIONS = %w[ add delete replace ]

  class InvalidAction < StandardError; end
  class InvalidMicroformat < StandardError; end

  def show
    case params[:q]
    when "config"
      render json: {
        "media-endpoint": media_url
      }, status: :ok
    when "syndicate-to"
      render json: { "syndicate-to": [] }, status: :ok
    when "source"
      resource = Micropub.resource_from_url(params[:url])
      if resource
        render json: format_resource_for_source(resource, params[:properties]), status: :ok
      else
        render json: {
          error: "not found",
          error_description: "Resource not found."
        }, status: :not_found
      end
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
        return send("form_#{action}_action")
      end

      if !action && microformat
        return form_create_action
      end

      raise InvalidMicroformat if !microformat
      raise InvalidAction
    end

    if request.content_type =~ CONTENT_TYPES[:JSON]
      action = params[:micropub][:action]
      microformat_sym = params[:type]&.first&.split("-")&.pop&.to_sym

      if valid_action = PERMITTED_ACTIONS.include?(action)
        return send("json_#{action}_action", Micropub.resource_from_url(params[:url]))
      end

      if !action && microformat = Micropub::MICROFORMAT_OBJECT_TYPES[microformat_sym]
        return json_create_action(microformat)
      end

      raise InvalidMicroformat if !microformat
      raise InvalidAction
    end
  end

  private

    def format_resource_for_source(resource, properties = [])
      microformat = Micropub::MICROFORMAT_OBJECT_TYPES[resource.class.name.downcase]

      # todo: error if microformat doesn't exist. maybe one level up.

      supported_properties = microformat[:supported_properties]
      properties_to_return = properties.to_a.any? ? properties & supported_properties : supported_properties

      properties = {}

      if properties_to_return.include?("name") && resource.name
        properties[:name] = [resource.name]
      end

      if properties_to_return.include?("content")
        if resource.content.present?
          properties[:content] = [resource.content]
        elsif resource.html_content.present?
          properties[:content] = [{ html: resource.html_content }]
        else
          [""]
        end
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

      if properties_to_return.include?("post-status")
        properties[:"post-status"] = [resource.status]
      end

      {
        type: ["h-entry"],
        properties: properties
      }
    end

    def form_create_action
      microformat = Micropub::MICROFORMAT_OBJECT_TYPES[params[:h].to_sym]

      raise InvalidMicroformat if !microformat

      resource = microformat[:class].new
      resource.blog = Current.blog

      if params[:name]
        resource.name = params[:name]
      end

      if params[:content]
        resource.content = params[:content]
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

        resource.categorizations_attributes = categorizations_attributes
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

        resource.microformat_photos_attributes = microformat_photos_attributes
      end

      resource.status = params[:"post-status"] == "draft" ? "draft" : "published"

      if resource.save
        response.headers["Location"] = entry_url(resource)
        head :created
      else
        head :unprocessable_entity
      end
    end

    def form_delete_action
      resource = Micropub.resource_from_url(params[:url])

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
      resource = Micropub.resource_from_url(params[:url])

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

      resource = microformat[:class].new
      resource.blog = Current.blog

      if properties[:name]&.any?
        resource.name = properties[:name].first
      end

      if properties[:content]&.any?
        content = properties[:content].first

        if content.class == String
          resource.content = content
          resource.html_content = nil
        end

        if content.class == ActionController::Parameters
          resource.content = nil
          resource.html_content = content[:html]
        end
      end

      if properties[:category]&.any?
        categorizations_attributes = properties[:category].map { |category|
          {
            category_attributes: {
              name: category
            }
          }
        }

        resource.categorizations_attributes = categorizations_attributes
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

        resource.microformat_photos_attributes = microformat_photos_attributes
      end

      if properties[:"post-status"]&.any?
        resource.status = properties[:"post-status"].first
      end

      if resource.save
        response.headers["Location"] = entry_url(resource)
        head :created
      else
        head :unprocessable_entity
      end
    end

    def json_delete_action(resource)
      if resource.update(deleted_at: Time.now)
        head :no_content
      else
        render json: {
          "error": "bad request",
          "error_description": "Something went wrong when deleting this resource."
        }, status: :bad_request
      end
    end

    def json_undelete_action(resource)
      if resource.update(deleted_at: nil)
        head :no_content
      else
        render json: {
          "error": "bad request",
          "error_description": "Something went wrong when undeleting this resource."
        }, status: :bad_request
      end
    end

    def json_update_action(resource)
      params[:micropub].each do |update_action, properties|
        if PERMITTED_UPDATE_ACTIONS.include?(update_action)
          if ![ActionController::Parameters, Array].include?(properties.class)
            return render json: {
              "error": "bad request",
              "error_description": "Invalid info provided."
            }, status: :bad_request
          end

          send("json_update_#{update_action}_action", resource, properties)
        end
      end

      if resource.save
        head :ok
      else
        render json: {
          "error": "unprocessable entity",
          "error_description": "Something went wrong when updating this resource."
        }, status: :unprocessable_entity
      end
    end

    def json_update_add_action(resource, properties)
      if properties[:category]&.any?
        categorizations_attributes = properties[:category].map { |category|
          {
            category_attributes: {
              name: category
            }
          }
        }

        resource.categorizations_attributes = categorizations_attributes
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

        resource.microformat_photos_attributes = microformat_photos_attributes
      end
    end

    def json_update_delete_action(resource, properties)
      # delete the whole property.
      if properties.is_a?(Array)

        if properties.include?("name")
          resource.name = nil
        end

        if properties.include?("content")
          resource.content = nil
          resource.html_content = nil
        end

        if properties.include?("category")
          resource.categorizations.delete_all
        end

        if properties.include?("photo")
          resource.microformat_photos.destroy_all
        end

      # remove some values inside the property.
      else
        if properties[:category]&.any?
          categories = Category.where(name: properties[:category])
          resource.categorizations.where(category: categories).delete_all
        end

        if properties[:photo]&.any?
          signed_ids = properties[:photo].map { |url| url.match(/redirect\/([^\/]+)\//)[1] }
          blobs = signed_ids.map { |signed_id| ActiveStorage::Blob.find_signed(signed_id) }

          blobs.each do |blob|
            record = blob.attachments.first.record
            MicroformatPhoto.find_by(photoable: resource, photo_with_alt: record).destroy
          end
        end
      end
    end

    def json_update_replace_action(resource, properties)
      if properties[:name]
        resource.name = properties[:name].first
      end

      if properties[:content]&.any?
        content = properties[:content].first

        if content.class == String
          resource.content = content
          resource.html_content = nil
        end

        if content.class == ActionController::Parameters
          resource.content = nil
          resource.html_content = content[:html]
        end
      end

      if properties[:"post-status"]
        resource.status = properties[:"post-status"].first
      end

      # todo?: category
      # todo?: photo
    end

    def ensure_blog
      if !Current.blog
        render json: {
          error: "invalid_request",
          error_description: "Invalid blog subdomain"
        }, status: :bad_request
      end
    end
end
