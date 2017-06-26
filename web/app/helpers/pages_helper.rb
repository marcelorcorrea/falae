module PagesHelper

  def add_item_button
    button_to(user_spreadsheet_page_add_item_path(@user, @spreadsheet, @page),
              {method: :get, form_class: "content add", class: 'add-button',
              remote: true }) do 
      fa_icon 'plus-circle'
    end
  end

  def remove_item_button(item_id)
    button_to(user_spreadsheet_page_remove_item_path(@user, @spreadsheet, @page),
              {method: :delete, class: :remove, data: {confirm: 'Are you sure?'},
              remote: true, params: {item_id: item_id}} ) do
      concat fa_icon 'trash-o', class: :default
      concat fa_icon 'trash', class: :hover
    end 
  end
end
