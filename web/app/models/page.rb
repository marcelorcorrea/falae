class Page < ApplicationRecord
  belongs_to :spreadsheet
  has_many :item_pages, dependent: :destroy
  has_many :items, through: :item_pages

  validates_associated :spreadsheet
  validates :name, presence: true, uniqueness: { scope: :spreadsheet }
  validates :columns, :rows, presence: true,
            numericality: { only_integer: true }

  def Page.default_blank
    Page.new name: 'Initial', columns: 6, rows: 3
  end

  def item_position(item)
    item_page = self.item_pages.find_by item_id: item.id
    item_page ? item_page.position : -1
  end

  def item_in_position(position)
    self.item_pages.find_by position: position
  end
end
