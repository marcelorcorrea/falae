class Page < ApplicationRecord
  belongs_to :spreadsheet
  has_many :item_page, dependent: :destroy
  has_many :items, through: :item_page

  validates_associated :spreadsheet
  validates :name, presence: true, uniqueness: { scope: :spreadsheet }
  validates :columns, :rows, presence: true,
            numericality: { only_integer: true }

  def Page.default
    page = Page.new name: 'Initial', columns: 6, rows: 3
    page.items << Item.defaults
    page
  end
end
