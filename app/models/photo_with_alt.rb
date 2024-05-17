class PhotoWithAlt < ApplicationRecord
  self.table_name = "photos_with_alt"

  has_one :microformat_photo
  has_one_attached :photo
end
