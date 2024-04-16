class Blog < ApplicationRecord
  belongs_to :user
  has_many :entries, -> { order(created_at: :desc) }, dependent: :destroy

  validates :title, presence: true
  validates :subdomain, format: { with: /\A[a-z-]+\z/, message: "only allows letters" }, length: { in: 3..20 }

  def to_param
    subdomain
  end
end
