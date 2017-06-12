module CategoriesHelper

  def display_name(category)
    category.name.downcase.humanize
  end


  def select_options_helper
    Category.all.map { |ctgy| [display_name(ctgy), ctgy.id] }
  end

  def CategoriesHelper.css_class_name(category)
    category.name.downcase.dasherize
  end

  def css_class_name(category)
    CategoriesHelper.css_class_name(category)
  end

end
