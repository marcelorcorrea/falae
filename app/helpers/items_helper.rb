module ItemsHelper
  def confirmation_message(item, string_id)
    pages = item.pages
    message = pages.map { |p| "\"#{p.name}\"" }.join(', ')
    t(string_id, pages: message, count: pages.size)
  end

  def edit_item_confirmation_message(item)
    confirmation_message item, '.edit_alert'
  end

  def destroy_item_confirmation_message(item)
    confirmation_message item, '.destroy_alert'
  end
end
