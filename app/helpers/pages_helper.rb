module PagesHelper
  #TODO should it be in ItemsHelper?
  def add_item_button
    button_to(add_item_user_spreadsheet_page_path(@user, @spreadsheet, @page),
              {method: :get, form_class: "content add", class: 'add-button',
               remote: true}) do
      fa_icon 'plus-circle'
    end
  end

  def edit_item_button(item_id, item_private)
    path = edit_item_user_spreadsheet_page_path(@user, @spreadsheet, @page)
    options = {
      method: :get,
      class: :edit,
      params: {
        item_id: item_id
      },
      remote: true
    }
    options[:data] = { confirm: t('views.item_edit_alert') } if item_private

    button_to(path, options) do
      concat fa_icon 'pencil-square-o', class: :default
      concat fa_icon 'pencil-square', class: :hover
    end
  end

  def remove_item_button(item_id, item_page_id)
    path = remove_item_user_spreadsheet_page_path(@user, @spreadsheet, @page)
    options = {
      method: :delete,
      class: :remove,
      data: {
        confirm: t('views.page_item_remove_alert')
      },
      params: {
        item_id: item_id,
        item_page_id: item_page_id
      },
      remote: true
    }

    button_to(path, options) do
      concat fa_icon 'trash-o', class: :default
      concat fa_icon 'trash', class: :hover
    end
  end

  def select_pages_names_options
    @spreadsheet.pages.map { |p| [p.name] }
  end

  def select_pages_options_helper
    pages = @spreadsheet.pages - [@page]
    pages.map { |p| [p.name, p.id] }
  end
end
