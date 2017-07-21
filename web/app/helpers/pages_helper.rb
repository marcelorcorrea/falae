module PagesHelper
  #TODO should it be in ItemsHelper?
  def add_item_button
    button_to(user_spreadsheet_page_add_item_path(@user, @spreadsheet, @page),
              {method: :get, form_class: "content add", class: 'add-button',
               remote: true}) do
      fa_icon 'plus-circle'
    end
  end

  def edit_item_button(item_id)
    unless @spreadsheet.pages.one?
      button_to(user_spreadsheet_page_edit_item_path(@user, @spreadsheet, @page),
                {method: :get, class: :edit, remote: true, params: {item_id: item_id}}) do
        concat fa_icon 'pencil-square-o', class: :default
        concat fa_icon 'pencil-square', class: :hover
      end
    end
  end

  def remove_item_button(item_id)
    button_to(user_spreadsheet_page_remove_item_path(@user, @spreadsheet, @page),
              {method: :delete, class: :remove, data: {confirm: 'Are you sure?'},
               remote: true, params: {item_id: item_id}}) do
      concat fa_icon 'trash-o', class: :default
      concat fa_icon 'trash', class: :hover
    end
  end

  def select_pages_options_helper
    pages = @spreadsheet.pages - [@page]
    pages.map { |p| [p.name, p.id] }
  end
end
