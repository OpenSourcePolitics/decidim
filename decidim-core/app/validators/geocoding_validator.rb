# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# an existing address and computes its coordinates.
class GeocodingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if Decidim.geocoder.present? && record.component.present?
      organization = record.component.organization
      Geocoder.configure(Geocoder.config.merge(http_headers: { "Referer" => organization.host }))
      coordinates = find_coordinates value

      if coordinates.present?
        record.latitude = coordinates.first
        record.longitude = coordinates.last
      else
        record.errors.add(attribute, :invalid)
      end
    else
      record.errors.add(attribute, :invalid)
    end
  end

  private

  def find_coordinates(value)
    return Geocoder.coordinates(value) unless restricted_to_country?

    Geocoder.coordinates(value, params: { country: Decidim.geocoder[:country_restriction] })
  end

  def restricted_to_country?
    Decidim.geocoder[:country_restriction].present?
  end
end
