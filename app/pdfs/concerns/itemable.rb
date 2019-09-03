module Itemable
  extend ActiveSupport::Concern
  include Prawn::View

  def build_item(item, x, y, width, height)
    bounding_box([x, y], width: width, height: height) do
      stroke_color '008383'
      item_ctgy_color = item.category.base_color.sub('#','')
      fill_color item_ctgy_color
      fill_and_stroke_rounded_rectangle [0, height], width, height, 5

      add_text_box item.name, item_ctgy_color, width, height
      add_image_box item.image.image.path, width, height
    end
  end

  def add_text_box(text, color, width, height)
    fill_color font_color color
    text_box text,
      align: :center,
      at: [0, height],
      height: height * 0.2,
      overflow: :truncate,
      size: height * 0.095,
      valign: :center,
      width: width
  end

  def add_image_box(image_path, width, height)
    bounding_box([0, height * 0.8], width: width, height: height * 0.8) do
      image image_path,
        at: [width * 0.6 - width / 2, height - height * 0.6 / 2],
        height: height * 0.6,
        position: :center,
        vposition: :center,
        width: height * 0.6
    end
  end

  private

  def brightness(rgb_color)
    red, green, blue = rgb_color.scan(/../).map { |c| c.hex / 255.0 }
    0.2126 * red + 0.7152 * green + 0.0722 * blue;
  end

  def font_color(rgb_color)
    brightness(rgb_color) > 0.179 ? '000000' : 'FFFFFF'
  end
end
