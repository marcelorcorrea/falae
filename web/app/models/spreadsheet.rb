class Spreadsheet < ApplicationRecord
  belongs_to :user
  has_many :pages, dependent: :destroy

  before_save do
    if self.pages.empty?
      default_blank_page = Page.default_blank
      self.pages << default_blank_page
      self.initial_page = default_blank_page.name
    end
  end

  #validates_associated :user
  validates :name, presence: true, uniqueness: { scope: :user }
  #TODO: validate existence of referenced initial_page when assign new value

  def Spreadsheet.default
    Spreadsheet.new name: 'Principal'
  end
end
