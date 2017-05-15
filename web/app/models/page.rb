class Page < ApplicationRecord
  belongs_to :spreadsheet
  #TODO: validate name uniqueness through spreadsheet
  validates :name, presence: true
end
