class Spreadsheet < ApplicationRecord
  belongs_to :user
  has_many :pages, dependent: :destroy

  # validates_associated :user
  validates :name, presence: true, uniqueness: { scope: :user }
  #TODO: validate existence of referenced initial_page when assign new value
end
