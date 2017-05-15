class Spreadsheet < ApplicationRecord
  belongs_to :user
  #TODO: validate name uniqueness through user
  validates :name, presence: true
end
