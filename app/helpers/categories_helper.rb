module CategoriesHelper
  def select_options_for_categories
    @all_ctgy ||= Category.all.map { |ctgy| [ctgy.description, ctgy.id] }
  end

  def category_id(item)
    return item.category.id if item.category
    Category.default.id
  end

  def CategoriesHelper.css_class_name(category)
    category.name.downcase.dasherize
  end

  def css_class_name(category)
    CategoriesHelper.css_class_name(category)
  end
end
