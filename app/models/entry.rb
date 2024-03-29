class Entry < ApplicationRecord
  has_many :categorizations, as: :categorizable, dependent: :destroy
  has_many :categories, through: :categorizations

  accepts_nested_attributes_for :categorizations, reject_if: :empty_or_assigned_category

  private

    def empty_or_assigned_category(attributes)
      category_name = attributes.dig(:category_attributes, :name)

      # reject if category name is empty:
      return true if !category_name.present?

      # reject if category is already assigned:
      if !attributes.dig(:id).present?
        assigned = self.categories.include? Category.find_by(name: category_name)
        return true if assigned
      end

      false
    end
end
