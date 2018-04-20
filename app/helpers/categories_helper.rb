module CategoriesHelper
  def select_options_for_categories
    Category.all_by_current_locale.map { |ctgy| [ctgy.description, ctgy.id] }
  end

  def category_id(item)
    item.category&.id || Category.default.id
  end

  def CategoriesHelper.css_class_name(category)
    category.base_name.downcase.dasherize
  end

  def css_class_name(category)
    CategoriesHelper.css_class_name(category)
  end
end
