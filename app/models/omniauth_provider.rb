class OmniauthProvider < ApplicationRecord
  belongs_to :user

  accepts_nested_attributes_for :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider, message: "is already in use." }
end
