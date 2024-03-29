class Categorization < ApplicationRecord
  belongs_to :category
  belongs_to :categorizable, polymorphic: true

  validates :category, uniqueness: { scope: [:categorizable], message: "can't be assigned more than once." }

  def category_attributes=(attributes)
    self.category = Category.find_or_create_by(attributes)
  end
end
