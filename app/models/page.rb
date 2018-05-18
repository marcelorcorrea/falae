class Page < ApplicationRecord
  belongs_to :spreadsheet
  has_many :item_pages, dependent: :destroy
  has_many :items, -> { select 'items.*, item_pages.link_to' },
           through: :item_pages

  validates_associated :spreadsheet
  validates :name, presence: true, uniqueness: { scope: :spreadsheet }
  validates :columns, :rows,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validates :columns, numericality: { less_than_or_equal_to: 10 }

  after_save do
    spreadsheet.update(initial_page: name) if spreadsheet.pages.count == 1
  end

  after_destroy do
    spreadsheet.update(initial_page: nil) if name == spreadsheet.initial_page
  end

  def get_linked_page_id(item_id)
    item_page = ItemPage.find_by(page_id: id, item_id: item_id)
    return nil unless item_page
    linked_page = spreadsheet.pages.find_by(name: item_page.link_to)
    linked_page&.id
  end

  def swap_items(id1, id2)
    ip1, ip2 = item_pages.where(item_id: [id1, id2])
    return false unless ip1 && ip2
    ip1_item_id = ip1.item_id
    ip1_link_to = ip1.link_to
    Page.transaction do
      u1 = ip1.update(item_id: ip2.item_id, link_to: ip2.link_to)
      u2 = ip2.update(item_id: ip1_item_id, link_to: ip1_link_to)
      raise ActiveRecord::Rollback unless u1 && u2
      true
    end
  end
end
