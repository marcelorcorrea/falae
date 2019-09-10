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

    x = bounds.width / 2 - page_width / 2
    y = bounds.height / 2 + page_height / 2

    bounding_box([x, y], width: page_width, height: page_height) do
      define_grid(columns: columns, rows: rows, gutter: 2)
      items = @page.items
      items.each_with_index do |item, idx|
        x = idx / columns % rows
        y = idx % columns

        grid(x, y).bounding_box do
          build_item(item, bounds.left, bounds.top, bounds.width, bounds.height)
        end

        next_idx = idx + 1
        if next_idx % (columns * rows) == 0 && next_idx % items.length != 0
          start_new_page
        end
      end
    end
  end

end
