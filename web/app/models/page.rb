class Page < ApplicationRecord
  belongs_to :spreadsheet
  has_many :item_pages, dependent: :destroy
  has_many :items, through: :item_pages

  validates_associated :spreadsheet
  validates :name, presence: true, uniqueness: {scope: :spreadsheet}
  validates :columns, :rows, presence: true,
            numericality: {only_integer: true}

  def Page.default_blank
    Page.new name: 'Initial', columns: 6, rows: 3
  end

  def swap_items(id_1, id_2)
    Page.transaction do
      i1, i2 = self.item_pages.where item_id: [id_1, id_2]
      i1.item_id, i2.item_id = i2.item_id, i1.item_id
      i1.save!
      i2.save!
    end
  rescue => e
    puts e.message
    false
  end

  def get_linked_page_id(item_id)
    ip = ItemPage.find_by page_id: self.id, item_id: item_id
    self.spreadsheet.pages.find_by(name: ip.link_to).id if ip
  end
end
