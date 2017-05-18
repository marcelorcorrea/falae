class Spreadsheet < ApplicationRecord
  belongs_to :user
  has_many :pages, dependent: :destroy

  before_save do
    if self.pages.empty?
      default_page = Page.default
      self.pages << default_page
      self.initial_page = default_page.name
    end
  end

  #validates_associated :user
  validates :name, presence: true, uniqueness: { scope: :user }
  #TODO: validate existence of referenced initial_page when assign new value

  def Spreadsheet.default
    Spreadsheet.new name: 'Principal'
  end
end
