module PagesHelper
  def add_item_button
    path = add_item_user_spreadsheet_page_path(@user, @spreadsheet, @page)
    options = {
      method: :get,
      class: 'items-list-item add-button',
      form_class: 'add-item-page',
      remote: true
    }

    button_to(path, options) do
      fa_icon 'plus-circle'
    end
  end

  def page_item_menu_icon(item)
    content_tag(:div, class: 'items-list-item-menu') do
      concat fa_icon('ellipsis-v')
      concat page_item_nav_menu(item)
    end
  end

  def page_item_nav_menu(item)
    content_tag :nav, class: 'items-list-item-menu-options' do
      concat page_edit_item(item)
      concat page_remove_item(item)
    end
  end

  def page_edit_item(item)
    path = edit_item_user_spreadsheet_page_path(
      @user,
      @spreadsheet,
      @page,
      item_id: item.id
    )
    options = {
      class: :edit,
      method: :get,
      remote: true
    }
    options[:data] = { confirm: t('.edit_alert') } if item.private?

    link_to path, options do
      concat fa_icon('pencil-square-o')
      concat t('.edit')
    end
  end

  def page_remove_item(item)
    path = remove_item_user_spreadsheet_page_path(
      @user,
      @spreadsheet,
      @page,
      item_id: item.id,
      item_page_id: item.item_page_id
    )
    options = {
      class: :remove,
      data: {
          confirm: t('.remove_alert')
      },
      method: :delete,
      remote: true
    }

    link_to path, options do
      concat fa_icon('trash-o')
      concat t('.remove')
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
