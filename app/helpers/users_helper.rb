module UsersHelper
  def available_locales_options
    AVAILABLE_LOCALES.map {|key, value| [value, key]}
  end
end
