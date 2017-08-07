module CategoriesHelper
  def select_options_helper
    Category.all.map { |ctgy| [ctgy.description, ctgy.id] }
  end

  def CategoriesHelper.css_class_name(category)
    category.name.downcase.dasherize
  end

  def css_class_name(category)
    CategoriesHelper.css_class_name(category)
  end
end
