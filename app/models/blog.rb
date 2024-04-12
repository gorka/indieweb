class Blog < ApplicationRecord
  belongs_to :user
  has_many :entries, -> { order(created_at: :desc) }, dependent: :destroy

  validates :title, presence: true
  validates :subdomain, presence: true # todo: better constraints

  def to_param
    subdomain
  end
end
