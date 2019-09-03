class PagePdf
  include Prawn::View
  include Itemable

  def initialize(page, opts={})
    options = {
      margin: [0, 0, 0, 0],
      page_layout: :landscape,
      page_size: 'A4'
    }.merge(opts)
    @page = page
    @document = Prawn::Document.new options
    build_pdf
  end

  def build_pdf
    ratio = 0.75
    max_page_width = 720
    max_page_height = 520
    item_height = 240
    item_width = item_height * ratio
    columns = @page.columns
    rows = @page.rows

    page_width = item_width * columns
    page_height = item_height * rows

    if page_height > max_page_height
      page_height = max_page_height
      item_height = page_height / rows
      item_width = item_height * ratio
      page_width = item_width * columns
    end

    if page_width > max_page_width
      page_width = max_page_width
      item_width = page_width / columns
      item_height = item_width / ratio
      page_height = item_height * rows
    end

    x = ((bounds.width / 2) - (page_width / 2))
    y = ((bounds.height / 2) + (page_height / 2))

    bounding_box([x, y], width: page_width, height: page_height) do
      page_items = @page.items
      page_items.each_slice(columns * rows).with_index do |page, idx|
        y_pos = bounds.height
        page.each_slice(columns).each do |items|
          x_pos = 0
          items.each do |item|
            build_item item, x_pos, y_pos, item_width, item_height
            x_pos += item_width
          end
          y_pos -= item_height
        end
        start_new_page unless page_items.size <= columns * rows || idx == rows - 1
      end
    end
  end

end
