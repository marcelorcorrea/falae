class ItemPdf
  include Prawn::View
  include Itemable

  def initialize(item, opts={})
    options = {
      margin: [0, 0, 0, 0],
      page_layout: :landscape,
      page_size: 'A4',
    }.merge(opts)
    @item = item
    @document = Prawn::Document.new options
    build_pdf
  end

  def build_pdf
    item_height = 250
    item_width = item_height * 0.75
    x_pos = bounds.width / 2 - item_width / 2
    y_pos = bounds.height / 2 + item_height / 2

    build_item @item, x_pos, y_pos, item_width, item_height
  end
end
