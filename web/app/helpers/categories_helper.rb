module CategoriesHelper

  def select_options_helper
    Category.all.map { |ctgy| [ctgy.name.downcase.humanize, ctgy.id] }
  end

  def ItemsHelper.css_class_name(category)
    category.name.downcase.dasherize
  end

  def css_class_name(category)
    ItemsHelper.css_class_name(category)
  end

end
