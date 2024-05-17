class MicroformatPhoto < ApplicationRecord
  belongs_to :photo_with_alt, dependent: :destroy
  belongs_to :photoable, polymorphic: true

  def photo_with_alt_attributes=(attributes)
    self.photo_with_alt = PhotoWithAlt.new(alt: attributes[:alt])
    self.photo_with_alt.photo.attach(io: attributes[:photo_data], filename: attributes[:photo_name])
  end
end
