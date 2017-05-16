class Page < ApplicationRecord
  belongs_to :spreadsheet, dependent: :destroy
  has_many :items

  validates_associated :spreadsheet
  validates :name, presence: true, uniqueness: { scope: :spreadsheet }
  validates :columns, :rows, presence: true,
            numericality: { only_integer: true }

  def Page.default
    @default_page ||= Page.new name: :page, columns: 4, rows: 3
  end
end
