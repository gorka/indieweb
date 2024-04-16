class User < ApplicationRecord
  has_many :blogs, dependent: :restrict_with_exception
  has_many :omniauth_providers, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
end
