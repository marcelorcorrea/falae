class ItemPage < ApplicationRecord
  belongs_to :item
  belongs_to :page

  after_destroy { item.destroy unless item.private?}
end
