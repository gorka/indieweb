class Category < ApplicationRecord
  has_many :categorizations, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
end
