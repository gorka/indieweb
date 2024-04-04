class User < ApplicationRecord
  has_many :omniauth_providers, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
end
