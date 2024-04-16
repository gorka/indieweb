class Blog < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :subdomain, format: { with: /\A[a-z-]+\z/, message: "only allows letters" }, length: { in: 3..20 }

  def to_param
    subdomain
  end
end
