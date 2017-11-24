class Page < ApplicationRecord
  belongs_to :spreadsheet
  has_many :item_pages, dependent: :destroy
  has_many :items, -> { select 'items.*, item_pages.link_to' },
    through: :item_pages

  validates_associated :spreadsheet
  validates :name, presence: true, uniqueness: {scope: :spreadsheet}
  validates :columns, :rows, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :columns, numericality: {less_than_or_equal_to: 10}

  def Page.default_blank
    Page.new name: 'Initial', columns: 6, rows: 3
  end

  def swap_items(id1, id2)
    Page.transaction do
      i1, i2 = item_pages.where item_id: [id1, id2]
      i1.item_id, i2.item_id = i2.item_id, i1.item_id
      i1.link_to, i2.link_to = i2.link_to, i1.link_to
      i1.save!
      i2.save!
    end
  rescue => e
    puts e.message
    false
  end

  def get_linked_page_id(item_id)
    item_page = ItemPage.find_by page_id: self.id, item_id: item_id
    return nil unless item_page
    linked_page = self.spreadsheet.pages.find_by name: item_page.link_to
    linked_page ? linked_page.id : nil
  end
end
