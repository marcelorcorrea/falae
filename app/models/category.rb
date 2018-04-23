class Category < ApplicationRecord
  belongs_to :base_category
  has_many :items

  validates :description, :locale, presence: true

  delegate :name, :color, to: :base_category, prefix: :base

  def Category.default
    Category.joins(:base_category)
      .find_by(locale: I18n.locale, base_categories: {name: 'OTHER'})
  end

  def Category.all_by_current_locale
    Category.where(locale: I18n.locale)
  end
end
